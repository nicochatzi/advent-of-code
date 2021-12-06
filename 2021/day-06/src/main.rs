fn generation(fishes: Vec<usize>) -> Vec<usize> {
    fishes.iter().fold(vec![], |mut next_gen, age| {
        if *age == 0 {
            next_gen.extend_from_slice(&[6, 8])
        } else {
            next_gen.push(age - 1)
        }
        next_gen
    })
}

fn run_n_generations(fishes: Vec<usize>, n: usize) -> usize {
    (0..n).fold(fishes, |fishes, _| generation(fishes)).len()
}

fn parse_input(input: &str) -> Vec<usize> {
    input
        .split(',')
        .map(|s| s.parse::<usize>().unwrap())
        .collect()
}

fn main() {
    println!(
        "star 11 : {}",
        run_n_generations(parse_input(include_str!("../res/data.txt")), 80)
    );
}

#[test]
fn can_find_aoc_input_result_star_11() {
    let aoc_input = parse_input("3,4,3,1,2");
    assert_eq!(run_n_generations(aoc_input.clone(), 18), 26);
    assert_eq!(run_n_generations(aoc_input.clone(), 80), 5934);
}
