__version__ = '0.1.0'


from typing import List, Tuple, Optional


class Board:
    def __init__(self, raw_input: str):
        self.inner = [(0, False)] * 5 * 5
        for i, line in enumerate(raw_input.split('\n')):
            l = [l for l in line.split(' ') if l != '']
            for j, s in enumerate(l):
                self.inner[(i*5)+j] = int(s), False

    def check(self) -> bool:
        for i in range(5):
            if all(hit == True for _, hit in self.inner[i*5:(i+1)*5]):
                return True
            if all(hit == True for _, hit in self.inner[i::5]):
                return True
        return False

    def result(self) -> Optional[int]:
        return sum(n for n, hit in self.inner if hit == False)

    def add(self, n: int):
        self.inner = list((x[0], True) if n == x[0] else x for x in self.inner)


def split_data(raw_data: str) -> Tuple[List[int], Board]:
    blocks = raw_data.split('\n\n')
    return list(map(int, blocks[0].split(','))), list(Board(b) for b in blocks[1:])


def play(nums: List[str], boards: List[Board]) -> Optional[int]:
    for n in nums:
        for b in boards:
            b.add(n)
            if b.check():
                return n * b.result()
    return None

if __name__ == '__main__':
    with open('res/data.txt') as f:
        nums, boards = split_data(f.read())
        print(f'star 6 : {play(nums, boards)}')