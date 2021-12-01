fn count_increases_with_windowing(table: &[usize], window_size: usize) -> usize {
    (0..(table.len() - window_size + 1))
        .fold((0, 0), |state, i| {
            let sum = table[i..(i + window_size)].iter().sum();
            if state.1 < sum && i != 0 {
                (state.0 + 1, sum)
            } else {
                (state.0, sum)
            }
        })
        .0
}

fn count_num_increases(table: &[usize]) -> usize {
    count_increases_with_windowing(table, 1)
}

fn count_windowed_increases(table: &[usize]) -> usize {
    count_increases_with_windowing(table, 3)
}

fn main() {
    println!(
        "star 0 : {}",
        count_num_increases(include!("../res/data.in"))
    );
    println!(
        "star 1 : {}",
        count_windowed_increases(include!("../res/data.in"))
    );
}

#[test]
fn can_count_increases() {
    assert_eq!(count_num_increases(&[0, 1]), 1);
    assert_eq!(count_num_increases(&[0, 0, 100, 100]), 1);
    assert_eq!(count_num_increases(&[100, 1, 100]), 1);
    assert_eq!(count_num_increases(&[2, 4, 2, 4, 2, 4]), 3);
    assert_eq!(count_num_increases(&[2, 0, 20, 100, 2, 4]), 3);

    assert_eq!(count_num_increases(&[usize::MIN]), 0);
    assert_eq!(count_num_increases(&[usize::MAX]), 0);
    assert_eq!(count_num_increases(&[100]), 0);
    assert_eq!(count_num_increases(&[1, 1, 1, 1, 1]), 0);
    assert_eq!(count_num_increases(&[10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]), 0);
}

#[test]
fn can_count_windowed_increases() {
    assert_eq!(count_increases_with_windowing(&[0, 0, 0], 1), 0);
    assert_eq!(count_increases_with_windowing(&[0, 0, 0], 2), 0);
    assert_eq!(count_increases_with_windowing(&[0, 0, 0], 3), 0);

    assert_eq!(count_increases_with_windowing(&[0, 1, 0], 1), 1);
    assert_eq!(count_increases_with_windowing(&[0, 1, 0], 2), 0);
    assert_eq!(count_increases_with_windowing(&[0, 1, 0], 3), 0);

    assert_eq!(count_increases_with_windowing(&[0, 1, 0, 1, 0, 1], 1), 3);
    assert_eq!(count_increases_with_windowing(&[0, 1, 0, 1, 0, 1], 2), 0);
    assert_eq!(count_increases_with_windowing(&[0, 1, 0, 1, 0, 1], 3), 2);

    assert_eq!(count_increases_with_windowing(&[0, 1, 1, 0, 1, 1], 1), 2);
    assert_eq!(count_increases_with_windowing(&[0, 1, 1, 0, 1, 1], 2), 2);
    assert_eq!(count_increases_with_windowing(&[0, 1, 1, 0, 1, 1], 3), 0);
}
