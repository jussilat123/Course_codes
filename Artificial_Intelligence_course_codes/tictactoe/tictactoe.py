"""
Tic Tac Toe Player
"""

import math
import numpy as np
import copy

X = "X"
O = "O"
EMPTY = None

def initial_state():
    """
    Returns starting state of the board.
    """
    return [[EMPTY, EMPTY, EMPTY],
            [EMPTY, EMPTY, EMPTY],
            [EMPTY, EMPTY, EMPTY]]


def player(board):
    """
    Returns player who has the next turn on a board.
    """
    count_of_X = 0
    count_of_O = 0
    for i in range(3):
        for j in range(3):
            if (board[i][j] == "X"):
                count_of_X += 1
            elif (board[i][j] == "O"):
                count_of_O += 1
    if(count_of_X == count_of_O):
        return X
    else:
        return O


def actions(board):
    """
    Returns set of all possible actions (i, j) available on the board.
    """
    actions = []
    for i in range(3):
        for j in range(3):
            if(board[i][j] == None):
                actions.append([i,j])
    return actions



def result(board, action):
    """
    Returns the board that results from making move (i, j) on the board.
    """
    player_of_turn = player(board)
    board[action[0]][action[1]] = player_of_turn
    return board



def winner(board):
    """
    Returns the winner of the game, if there is one.
    """
    # states = [row1,row2,row3,col1,col2,col3,diag1,diag2]

    # rows
    for i in range(3):
        if (board[i][0] == board[i][1] == board[i][2]) and (board[i][0] != None):
            return board[i][0]

    # columns
    for j in range(3):
        if (board[0][j] == board[1][j] == board[2][j]) and (board[0][j] != None):
            return board[0][j]

    #diag1
    if (board[0][0] == board[1][1] == board[2][2]) and (board[2][2] != None):
        return board[0][0]

    #diag2
    if (board[0][2] == board[1][1] == board[2][0]) and (board[1][1] != None):
        return board[1][1]

    return None


def terminal(board):
    """
    Returns True if game is over, False otherwise.
    """

    #if board is full
    counter = 0
    for i in range(3):
        for j in range(3):
            if (board[i][j] != None):
                counter += 1
    if (counter == 9):
        return True

    winner_of_board = winner(board)
    if (winner_of_board == None):
        return False
    else:
        return True


def utility(board):
    """
    Returns 1 if X has won the game, -1 if O has won, 0 otherwise.
    """
    winner_of_game = winner(board)

    if(winner_of_game == "X"):
        return 1
    elif(winner_of_game == "O"):
        return -1
    else:
        return 0

def count(x_vector):
    #returns vector where X3,X2,X1,03,02,01
    counter_X = 0
    counter_O = 0
    for i in range(3):
        if (x_vector[i] == "X"):
            counter_X += 1
        elif (x_vector[i] == "O"):
            counter_O += 1

    #no line found
    if(counter_X > 0 and counter_O >0):
        return np.array([0,0,0,0,0,0])
    elif(counter_X ==1):
        return np.array([0,0,1,0,0,0])
    elif (counter_X == 2):
        return np.array([0, 1, 0, 0, 0, 0])
    elif (counter_X == 3):
        return np.array([1, 0, 0, 0, 0, 0])
    elif (counter_O == 1):
        return np.array([0,0,0,0,0,1])
    elif (counter_O == 2):
        return np.array([0,0,0,0,1,0])
    elif (counter_O == 3):
        return np.array([0,0,0,1,0,0])
    #all None
    else:
        return np.array([0,0,0,0,0,0])

def eval_function(board):
    players_turn = player(board)

    #should be kind of vice versa but this works. So...
    if(players_turn == "O"):
        weight_vector = np.array([500, 3, 1, -500, -3, -1])
    else:
        weight_vector = np.array([-500, -3, -1, 500, 3, 1])
    #3*X_2+X_1 - 3*O_2 -O_1 + (500*X_3 -500*O_3)

    eval_vector = np.array([0,0,0,0,0,0])

    #rows
    for i in range(3):
        x_vector = [board[i][0],board[i][1],board[i][2]]
        eval_vector += count(x_vector)

    #columns
    for i in range(3):
        eval_vector += count([board[0][i],board[1][i],board[2][i]])

    #diag1
    eval_vector += count([board[0][0], board[1][1], board[2][2]])

    #diag2
    eval_vector += count([board[0][2], board[1][1], board[2][0]])

    return weight_vector.dot(eval_vector)

def do_actions(board,actions_list):
    # does actions in min - max order seeking two moves further
    eval_points = []

    for i in range(len(actions_list)):
        board_y = copy.deepcopy(board)
        board_x = result(board_y,actions_list[i])

        #lets examine second turn
        possible_actions_to_do_in_2nd_round = actions(board_x)
        Second_loop_eval_points = []
        for j in range(len(possible_actions_to_do_in_2nd_round)):
            board_z = copy.deepcopy(board_x)
            board_z2 = result(board_z,possible_actions_to_do_in_2nd_round[j])
            Second_loop_eval_points.append(eval_function(board_z2))

        if (len(Second_loop_eval_points) == 0):
            eval_points.append(0)
        else:
            eval_points.append(max(Second_loop_eval_points))


    eval_points = np.array(eval_points)

    return actions_list[eval_points.argmin()]

def minimax(board):
    """
    Returns the optimal action for the current player on the board.
    """
    if (terminal(board)):
        return None

    board1 = copy.deepcopy(board)

    possible_actions1 = actions(board1)
    best_action = do_actions(board1,possible_actions1)

    return best_action