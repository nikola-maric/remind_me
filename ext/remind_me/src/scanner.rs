use memchr::memmem;
use std::fs;
use std::path::Path;
use std::sync::Mutex;

const MARKER: &str = "REMIND_ME:";
const MARKER_LEN: usize = 10; // "REMIND_ME:".len()

/// A single REMIND_ME comment match with its source location and text.
pub struct Match {
    pub source_location: String,
    pub comment_text: String,
}

/// Scan a single file for REMIND_ME comments.
///
/// Handles both single-line (`# REMIND_ME: ...`) and block (`=begin`/`=end`) comments.
/// Returns matches as (source_location, comment_text) where:
/// - source_location is "path:line:1"
/// - comment_text is everything after "REMIND_ME:" on the matching line
pub fn scan_file(file_path: &str) -> Vec<Match> {
    let content = match fs::read_to_string(file_path) {
        Ok(c) => c,
        Err(_) => return Vec::new(),
    };

    // Quick check: skip file entirely if no REMIND_ME: present
    if memmem::find(content.as_bytes(), MARKER.as_bytes()).is_none() {
        return Vec::new();
    }

    let lines: Vec<&str> = content.lines().collect();

    // First pass: identify =begin/=end block comment boundaries
    let mut block_ranges: Vec<(usize, usize)> = Vec::new();
    let mut current_begin: Option<usize> = None;
    for (i, line) in lines.iter().enumerate() {
        if line.starts_with("=begin") && current_begin.is_none() {
            current_begin = Some(i + 1); // 1-indexed
        } else if line.starts_with("=end") {
            if let Some(begin_line) = current_begin {
                block_ranges.push((begin_line, i + 1));
                current_begin = None;
            }
        }
    }

    // Second pass: find REMIND_ME: on each line
    let finder = memmem::Finder::new(MARKER);
    let mut results = Vec::new();

    for (i, line) in lines.iter().enumerate() {
        let line_num = i + 1; // 1-indexed

        if let Some(pos) = finder.find(line.as_bytes()) {
            let comment_text = &line[pos + MARKER_LEN..];

            // Determine if this match is inside a comment
            let in_block = block_ranges
                .iter()
                .any(|(begin, end)| line_num >= *begin && line_num <= *end);

            if in_block {
                // Block comment: report the =begin line number
                let begin_line = block_ranges
                    .iter()
                    .find(|(begin, end)| line_num >= *begin && line_num <= *end)
                    .map(|(begin, _)| *begin)
                    .unwrap();

                results.push(Match {
                    source_location: format!("{}:{}:1", file_path, begin_line),
                    comment_text: comment_text.to_string(),
                });
            } else if line[..pos].contains('#') {
                // Single-line comment: # appears before REMIND_ME:
                results.push(Match {
                    source_location: format!("{}:{}:1", file_path, line_num),
                    comment_text: comment_text.to_string(),
                });
            }
            // Otherwise: REMIND_ME: in code/string, skip it
        }
    }

    results
}

/// Walk a directory (or scan a single file) for REMIND_ME comments in .rb files.
/// Returns a Vec of (source_location, comment_text) tuples.
pub fn scan_for_remind_me_comments(path: &str) -> Vec<(String, String)> {
    let p = Path::new(path);

    if p.is_file() {
        return scan_file(path)
            .into_iter()
            .map(|m| (m.source_location, m.comment_text))
            .collect();
    }

    // Directory mode: parallel walk with ignore crate
    let results: Mutex<Vec<(String, String)>> = Mutex::new(Vec::new());

    ignore::WalkBuilder::new(path)
        .hidden(false)
        .git_ignore(false)
        .git_global(false)
        .git_exclude(false)
        .build_parallel()
        .run(|| {
            Box::new(|entry| {
                if let Ok(entry) = entry {
                    let entry_path = entry.path();
                    if entry_path.is_file()
                        && entry_path.extension().map_or(false, |ext| ext == "rb")
                    {
                        if let Some(path_str) = entry_path.to_str() {
                            let matches = scan_file(path_str);
                            if !matches.is_empty() {
                                let mut r = results.lock().unwrap();
                                for m in matches {
                                    r.push((m.source_location, m.comment_text));
                                }
                            }
                        }
                    }
                }
                ignore::WalkState::Continue
            })
        });

    results.into_inner().unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_single_line_comment() {
        let content = "# some comment\n# REMIND_ME: { gem: 'rails' }\ncode here\n";
        let tmp = std::env::temp_dir().join("test_single_line.rb");
        fs::write(&tmp, content).unwrap();
        let matches = scan_file(tmp.to_str().unwrap());
        assert_eq!(matches.len(), 1);
        assert!(matches[0].source_location.ends_with(":2:1"));
        assert_eq!(matches[0].comment_text, " { gem: 'rails' }");
        fs::remove_file(&tmp).ok();
    }

    #[test]
    fn test_block_comment() {
        let content = "=begin\n  some text\n  REMIND_ME: { gem: 'rails' }\n=end\n";
        let tmp = std::env::temp_dir().join("test_block_comment.rb");
        fs::write(&tmp, content).unwrap();
        let matches = scan_file(tmp.to_str().unwrap());
        assert_eq!(matches.len(), 1);
        assert!(matches[0].source_location.ends_with(":1:1")); // points to =begin
        assert_eq!(matches[0].comment_text, " { gem: 'rails' }");
        fs::remove_file(&tmp).ok();
    }

    #[test]
    fn test_remind_me_in_string_skipped() {
        let content = "puts \"REMIND_ME: something\"\n";
        let tmp = std::env::temp_dir().join("test_in_string.rb");
        fs::write(&tmp, content).unwrap();
        let matches = scan_file(tmp.to_str().unwrap());
        assert_eq!(matches.len(), 0);
        fs::remove_file(&tmp).ok();
    }

    #[test]
    fn test_no_matches() {
        let content = "# just a comment\nputs 'hello'\n";
        let tmp = std::env::temp_dir().join("test_no_match.rb");
        fs::write(&tmp, content).unwrap();
        let matches = scan_file(tmp.to_str().unwrap());
        assert_eq!(matches.len(), 0);
        fs::remove_file(&tmp).ok();
    }

    #[test]
    fn test_multiple_matches() {
        let content = "# REMIND_ME: { gem: 'a' }\n# regular\n# REMIND_ME: { gem: 'b' }\n";
        let tmp = std::env::temp_dir().join("test_multiple.rb");
        fs::write(&tmp, content).unwrap();
        let matches = scan_file(tmp.to_str().unwrap());
        assert_eq!(matches.len(), 2);
        assert!(matches[0].source_location.ends_with(":1:1"));
        assert!(matches[1].source_location.ends_with(":3:1"));
        fs::remove_file(&tmp).ok();
    }

    #[test]
    fn test_mixed_comment_types() {
        let content = "# REMIND_ME: { gem: 'a' }\n=begin\n  REMIND_ME: { gem: 'b' }\n=end\n";
        let tmp = std::env::temp_dir().join("test_mixed.rb");
        fs::write(&tmp, content).unwrap();
        let matches = scan_file(tmp.to_str().unwrap());
        assert_eq!(matches.len(), 2);
        assert!(matches[0].source_location.ends_with(":1:1")); // single-line
        assert!(matches[1].source_location.ends_with(":2:1")); // block, points to =begin
        fs::remove_file(&tmp).ok();
    }
}
