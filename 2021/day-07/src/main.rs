fn find_lsd_with_func(values: &[isize], func: impl Fn(isize, isize) -> isize) -> isize {
    let max = *values.iter().max().unwrap();
    let min = *values.iter().min().unwrap();
    (min..=max).fold(isize::MAX, |lsd, n| {
        values
            .iter()
            .fold(0, |diff_sum, x| diff_sum + func(*x, n))
            .min(lsd)
    })
}

fn find_lsd(values: &[isize]) -> isize {
    find_lsd_with_func(values, |a, b| (a - b).abs())
}

fn find_lsd_with_weighted_step(values: &[isize]) -> isize {
    find_lsd_with_func(values, |a, b| (1..=(a - b).abs()).sum::<isize>())
}

fn parse_input(s: &str) -> Vec<isize> {
    s.split(',').map(|s| s.parse::<isize>().unwrap()).collect()
}

fn main() {
    println!(
        "star 12 : {}",
        find_lsd(&parse_input(include_str!("../res/data.txt")))
    );
    println!(
        "star 13 : {}",
        find_lsd_with_weighted_step(&parse_input(include_str!("../res/data.txt")))
    );
}

#[cfg(test)]
fn aoc_input() -> Vec<isize> {
    parse_input("16,1,2,0,4,2,7,1,2,14")
}

#[test]
fn can_find_aoc_input_result_star_12() {
    assert_eq!(find_lsd(&aoc_input()), 37);
}

#[test]
fn can_find_aoc_input_result_star_13() {
    assert_eq!(find_lsd_with_weighted_step(&aoc_input()), 168);
}
