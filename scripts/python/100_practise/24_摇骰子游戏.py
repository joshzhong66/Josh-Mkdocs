# 游戏规则（P73）：
# - 构建摇色子的函数，需要摇3个塞子，每个塞子都生成1~6的随机数;
# - 创建1个列表，把摇塞子的结果存储在列表，并且每局都更换结果，每次游戏开始前，列表被清空一次;
# - 3个塞子的分别的点数，要转换为‘大’或‘小’，11<=总值<=18 为大，3<=总值<=10为小
# - 最后让用户猜大小，如果猜对告诉用户赢得结果，如果猜错就告诉用户输的结果

import random
def roll_dice(numbers=3,points=None):
    print('<<<ROLL THE DICE!>>>')
    if points is None:
        points=[]
    while numbers>0:
        point =random.randrange(1,7)
        points.append(point)
        numbers = numbers-1
    return points

def roll_result(total):
    isBig=11<=total<=18
    isSmall=3<=total<=10
    if isBig:
        return 'Big'
    if isSmall:
        return 'Small'

def start_game():
    print('<<<GAME STARTS!>>>')
    choices = ['Big','Small']
    your_choices =input('Big or Small: ')
    if your_choices in choices:
        points = roll_dice()
        total = sum(points)
        youWin = your_choices == roll_result(total)
        if youWin:
            print('The points are ',points,'You Win !')
        else:
            print('The points are ',points,'You lose !')
    else:
        print('Invalid Words')
        start_game()
start_game()
