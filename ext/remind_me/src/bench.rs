use std::env;
use std::time::Instant;

use remind_me_native::scanner;

fn main() {
    let path = env::args()
        .nth(1)
        .unwrap_or_else(|| ".".to_string());
    let iterations: usize = env::args()
        .nth(2)
        .and_then(|s| s.parse().ok())
        .unwrap_or(100);

    println!("Scanning: {}", path);
    println!("Iterations: {}", iterations);

    // Warmup
    let results = scanner::scan_for_remind_me_comments(&path);
    println!("Found {} REMIND_ME comments", results.len());
    for (loc, text) in &results {
        println!("  {} {}", loc, text.trim());
    }
    println!();

    // Benchmark
    let start = Instant::now();
    for _ in 0..iterations {
        let _ = scanner::scan_for_remind_me_comments(&path);
    }
    let elapsed = start.elapsed();

    println!("Total: {:.3}s ({} iterations)", elapsed.as_secs_f64(), iterations);
    println!("Per iteration: {:.4}s", elapsed.as_secs_f64() / iterations as f64);
}
