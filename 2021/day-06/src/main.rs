#[derive(Debug, Default, Clone)]
struct School([usize; 9]);

impl School {
    fn from_str(s: &str) -> Self {
        Self(
            s.split(',')
                .map(|s| s.parse::<usize>().unwrap())
                .fold([0; 9], |mut school, fish| {
                    school[fish] += 1;
                    school
                }),
        )
    }

    fn generation(&mut self) {
        *self = (0..9).fold(School::default(), |mut school, age| {
            if age == 0 {
                school.0[6] += self.0[age];
                school.0[8] += self.0[age];
            } else {
                school.0[age - 1] += self.0[age];
            }
            school
        });
    }

    fn run_n_generations(&mut self, n: usize) -> usize {
        (0..n).for_each(|_| self.generation());
        self.0.iter().sum()
    }
}

fn main() {
    println!(
        "star 11 : {}",
        School::from_str(include_str!("../res/data.txt")).run_n_generations(80)
    );
    println!(
        "star 12 : {}",
        School::from_str(include_str!("../res/data.txt")).run_n_generations(256)
    );
}

#[cfg(test)]
fn aoc_input() -> School {
    School::from_str("3,4,3,1,2")
}

#[test]
fn can_find_aoc_input_result_star_11() {
    let mut fishes = aoc_input();
    assert_eq!(fishes.clone().run_n_generations(18), 26);
    assert_eq!(fishes.run_n_generations(80), 5934);
}

#[test]
fn can_find_aoc_input_result_star_12() {
    assert_eq!(aoc_input().run_n_generations(256), 26_984_457_539);
}
