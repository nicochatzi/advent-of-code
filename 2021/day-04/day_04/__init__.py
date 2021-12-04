__version__ = '0.1.0'


from typing import List, Tuple, Optional


class Board:
    def __init__(self, raw_input: str):
        self.inner = [(0, False)] * 5 * 5
        for i, line in enumerate(raw_input.split('\n')):
            l = [l for l in line.split(' ') if l != '']
            for j, s in enumerate(l):
                self.inner[(i*5)+j] = int(s), False

    def won(self) -> bool:
        for i in range(5):
            if all(hit == True for _, hit in self.inner[i*5:(i+1)*5]):
                return True
            if all(hit == True for _, hit in self.inner[i::5]):
                return True
        return False

    def result(self) -> int:
        return sum(n for n, hit in self.inner if hit == False)

    def add(self, n: int):
        self.inner = list((x[0], True) if n == x[0] else x for x in self.inner)


def split_data(raw_data: str) -> Tuple[List[int], List[Board]]:
    blocks = raw_data.split('\n\n')
    return list(map(int, blocks[0].split(','))), list(Board(b) for b in blocks[1:])


def play(nums: List[int], boards: List[Board]) -> Optional[Tuple[int, int, List[Board]]]:
    for n in nums:
        for b in boards:
            b.add(n)
            if b.won():
                return n, b.result(), boards
    return None


def get_winning_result(nums: List[str], boards: List[Board]) -> int:
    n, res, _ = play(nums, boards)
    return n * res


def get_loosing_result(nums: List[str], boards: List[Board]) -> int:
    if len(boards) == 1:
        n, res, boards = play(nums, boards.copy())
        return n * res
    _, _, boards = play(nums, boards.copy())
    return get_loosing_result(nums, list(b for b in boards if not b.won()))


if __name__ == '__main__':
    with open('res/data.txt') as f:
        nums, boards = split_data(f.read())
        print(f'star 6 : {get_winning_result(nums, boards)}')
        print(f'star 7 : {get_loosing_result(nums, boards)}')
