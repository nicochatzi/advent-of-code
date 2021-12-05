use std::collections::HashMap;

#[derive(Debug, Default, PartialEq, Eq, Hash)]
struct Point {
    x: isize,
    y: isize,
}

impl Point {
    fn new(x: isize, y: isize) -> Self {
        Self { x, y }
    }
}

#[derive(Debug)]
struct Line {
    a: Point,
    b: Point,
}

impl Line {
    fn new(a: Point, b: Point) -> Self {
        Self { a, b }
    }

    fn from_str(s: &str) -> Self {
        let n = s
            .split(" -> ")
            .map(|s| s.split(",").map(|v| v.parse::<isize>().unwrap()).collect())
            .collect::<Vec<Vec<isize>>>();
        Self::new(Point::new(n[0][0], n[0][1]), Point::new(n[1][0], n[1][1]))
    }

    fn is_horizontal(&self) -> bool {
        self.a.y == self.b.y
    }

    fn is_vertical(&self) -> bool {
        self.a.x == self.b.x
    }

    fn is_diagonal(&self) -> bool {
        (self.a.x - self.b.x).abs() == (self.a.y - self.b.y).abs()
    }
}

#[derive(Debug, Default)]
struct Mapping {
    points: HashMap<Point, isize>,
}

impl Mapping {
    fn add(&mut self, line: &Line) {
        let start = Point::new(line.b.x.min(line.a.x), line.b.y.min(line.a.y));
        let steps = Point::new((line.b.x - line.a.x).abs(), (line.b.y - line.a.y).abs());

        if line.is_horizontal() {
            (0..=steps.x).for_each(|n| self.add_point(Point::new(start.x + n, start.y)));
        } else if line.is_vertical() {
            (0..=steps.y).for_each(|n| self.add_point(Point::new(start.x, start.y + n)));
        } else {
            for n in 0..=steps.x {
                let x = if line.a.x < line.b.x { line.a.x + n} else { line.a.x - n };
                let y = if line.a.y < line.b.y { line.a.y + n} else { line.a.y - n };
                self.add_point(Point::new(x, y));
            }
        }
    }

    fn dangerous_points(&self) -> isize {
        self.points
            .values()
            .fold(0, |acc, x| if *x > 1 { acc + 1 } else { acc })
    }

    fn add_point(&mut self, point: Point) {
        self.points
            .entry(point)
            .and_modify(|v| *v += 1)
            .or_insert(1);
    }
}

fn num_dangerous_points_with_filter(s: &str, pred: impl Fn(&Line) -> bool) -> isize {
    s.lines()
        .map(Line::from_str)
        .filter(pred)
        .fold(Mapping::default(), |mut map, line| {
            map.add(&line);
            map
        })
        .dangerous_points()
}

fn num_dangerous_non_diagonal_points(s: &str) -> isize {
    num_dangerous_points_with_filter(s, |l| l.is_horizontal() || l.is_vertical())
}

fn num_dangerous_points(s: &str) -> isize {
    num_dangerous_points_with_filter(s, |l| {
        l.is_horizontal() || l.is_vertical() || l.is_diagonal()
    })
}

fn main() {
    println!(
        "star 9 : {}",
        num_dangerous_non_diagonal_points(include_str!("../res/data.txt"))
    );
    println!(
        "star 10 : {}",
        num_dangerous_points(include_str!("../res/data.txt"))
    );
}

#[cfg(test)]
const AOC_INPUT: &str = "0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2";

#[test]
fn can_find_aoc_input_result_star_9() {
    assert_eq!(num_dangerous_non_diagonal_points(AOC_INPUT), 5);
}

#[test]
fn can_find_aoc_input_result_star_10() {
    assert_eq!(num_dangerous_points(AOC_INPUT), 12);
}
