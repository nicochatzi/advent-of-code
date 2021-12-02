use std::str::FromStr;

#[derive(Debug, PartialEq)]
enum Direction {
    Up(i32),
    Down(i32),
    Forward(i32),
    Back(i32),
}

impl FromStr for Direction {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let parse = |x: &str| x.parse::<i32>().map_err(|_| ());
        match s.split_once(' ').ok_or(())? {
            ("up", x) => Ok(Direction::Up(parse(x)?)),
            ("down", x) => Ok(Direction::Down(parse(x)?)),
            ("forward", x) => Ok(Direction::Forward(parse(x)?)),
            ("back", x) => Ok(Direction::Back(parse(x)?)),
            _ => Err(()),
        }
    }
}

#[derive(Debug, PartialEq)]
struct Directions(Vec<Direction>);

impl FromStr for Directions {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(Self(
            s.split_terminator('\n')
                .map(|dir| Direction::from_str(dir).unwrap())
                .collect(),
        ))
    }
}

impl Directions {
    fn sum(&self) -> (i32, i32) {
        self.0.iter().fold((0, 0), |state, dir| match dir {
            Direction::Up(x) => (state.0, state.1 - x),
            Direction::Down(x) => (state.0, state.1 + x),
            Direction::Forward(x) => (state.0 + x, state.1),
            Direction::Back(x) => (state.0 - x, state.1),
        })
    }

    fn product(&self) -> i32 {
        let sum = self.sum();
        sum.0 * sum.1
    }
}

fn main() {
    println!(
        "star 0 : {}",
        Directions::from_str(include_str!("../res/data.in"))
            .unwrap()
            .product()
    );
}

#[test]
fn can_get_direction_from_str() {
    assert_eq!(Direction::from_str("up 0").unwrap(), Direction::Up(0));
    assert_eq!(Direction::from_str("up 1").unwrap(), Direction::Up(1));
    assert_eq!(Direction::from_str("down 0").unwrap(), Direction::Down(0));
    assert_eq!(Direction::from_str("down 1").unwrap(), Direction::Down(1));
    assert_eq!(
        Direction::from_str("forward 0").unwrap(),
        Direction::Forward(0)
    );
    assert_eq!(
        Direction::from_str("forward 1").unwrap(),
        Direction::Forward(1)
    );
    assert_eq!(Direction::from_str("back 0").unwrap(), Direction::Back(0));
    assert_eq!(Direction::from_str("back 1").unwrap(), Direction::Back(1));
}

#[test]
fn can_get_directions_from_str() {
    let raw_directions = r"forward 13
down 1
back 10
down 2
down 12
up 50";
    assert_eq!(
        Directions::from_str(raw_directions).unwrap().0,
        vec![
            Direction::Forward(13),
            Direction::Down(1),
            Direction::Back(10),
            Direction::Down(2),
            Direction::Down(12),
            Direction::Up(50)
        ]
    );
}

#[test]
fn can_accumulate_directions() {
    let raw_directions = r"forward 13
down 12";
    assert_eq!(
        Directions::from_str(raw_directions).unwrap().sum(),
        (13, 12)
    );
    assert_eq!(
        Directions::from_str(raw_directions).unwrap().product(),
        13 * 12
    );

    let raw_directions = r"forward 13
down 12
up 10
forward 1
back 2
up 1
down 50";
    assert_eq!(
        Directions::from_str(raw_directions).unwrap().sum(),
        (12, 51)
    );
    assert_eq!(
        Directions::from_str(raw_directions).unwrap().product(),
        12 * 51
    );
}
