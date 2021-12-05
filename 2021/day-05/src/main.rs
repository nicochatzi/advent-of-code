use std::collections::HashMap;

#[derive(Debug, Default, PartialEq, Eq, Hash)]
struct Point {
    x: usize,
    y: usize,
}

impl Point {
    fn new(x: usize, y: usize) -> Self {
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
            .map(|s| s.split(",").map(|v| v.parse::<usize>().unwrap()).collect())
            .collect::<Vec<Vec<usize>>>();
        Self::new(Point::new(n[0][0], n[0][1]), Point::new(n[1][0], n[1][1]))
    }

    fn is_horizontal(&self) -> bool {
        self.a.y == self.b.y
    }

    fn is_vertical(&self) -> bool {
        self.a.x == self.b.x
    }
}

#[derive(Debug, Default)]
struct Mapping {
    points: HashMap<Point, usize>,
}

impl Mapping {
    fn add(&mut self, line: &Line) {
        if line.is_horizontal() {
            let steps = (line.b.x as isize - line.a.x as isize).abs() as usize + 1;
            let start = line.b.x.min(line.a.x);
            (0..steps).for_each(|n| self.add_point(Point::new(start + n, line.a.y)));
        }
        if line.is_vertical() {
            let steps = (line.b.y as isize - line.a.y as isize).abs() as usize + 1;
            let start = line.b.y.min(line.a.y);
            (0..steps).for_each(|n| self.add_point(Point::new(line.a.x, start + n)));
        }
    }

    fn dangerous_points(&self) -> usize {
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

fn num_dangerous_points(s: &str) -> usize {
    s.lines()
        .map(Line::from_str)
        .filter(|l| l.is_horizontal() || l.is_vertical())
        .fold(Mapping::default(), |mut map, line| {
            map.add(&line);
            map
        })
        .dangerous_points()
}

fn main() {
    println!(
        "star 9 : {}",
        num_dangerous_points(include_str!("../res/data.txt"))
    );
}

#[test]
fn can_find_aoc_input_result() {
    let aoc_input = "0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2";
    assert_eq!(num_dangerous_points(aoc_input), 5);
}
