fn count_num_increases(table: &[u32]) -> u32 {
    table
        .iter()
        .fold((0u32, u32::MAX), |state, current| {
            if state.1 < *current {
                (state.0 + 1, *current)
            } else {
                (state.0, *current)
            }
        })
        .0
}

fn main() {
    println!("{}", count_num_increases(include!("../res/data.in")));
}

#[test]
fn can_count_increases() {
    assert_eq!(count_num_increases(&[0, 1]), 1);
    assert_eq!(count_num_increases(&[0, 0, 100, 100]), 1);
    assert_eq!(count_num_increases(&[100, 1, 100]), 1);
    assert_eq!(count_num_increases(&[2, 4, 2, 4, 2, 4]), 3);
    assert_eq!(count_num_increases(&[2, 0, 20, 100, 2, 4]), 3);

    assert_eq!(count_num_increases(&[u32::MIN]), 0);
    assert_eq!(count_num_increases(&[u32::MAX]), 0);
    assert_eq!(count_num_increases(&[100]), 0);
    assert_eq!(count_num_increases(&[1, 1, 1, 1, 1]), 0);
    assert_eq!(count_num_increases(&[10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]), 0);
}