enum Player {
    case x
    case o
    
    var opponent: Player {
        switch self {
        case .x: return .o
        case .o: return .x
        }
    }
}

// Add Equatable conformance to GameState
enum GameState: Equatable {
    case inProgress
    case won(Player)
    case draw
    
    // Custom implementation of == for GameState
    static func == (lhs: GameState, rhs: GameState) -> Bool {
        switch (lhs, rhs) {
        case (.inProgress, .inProgress):
            return true
        case (.draw, .draw):
            return true
        case (.won(let player1), .won(let player2)):
            return player1 == player2
        default:
            return false
        }
    }
}

class TicTacToeGame {
    private var board: [[Player?]]
    private(set) var currentPlayer: Player
    private(set) var gameState: GameState
    
    init() {
        // Initialize empty 3x3 board
        board = Array(repeating: Array(repeating: nil, count: 3), count: 3)
        currentPlayer = .x  // X starts first
        gameState = .inProgress
    }
    
    func makeMove(row: Int, col: Int) -> Bool {
        // Check if move is valid
        guard row >= 0 && row < 3 && col >= 0 && col < 3 &&
              board[row][col] == nil && gameState == .inProgress else {
            return false
        }
        
        // Make the move
        board[row][col] = currentPlayer
        
        // Check for win
        if checkWin(for: currentPlayer) {
            gameState = .won(currentPlayer)
        }
        // Check for draw
        else if isBoardFull() {
            gameState = .draw
        }
        // Switch players if game continues
        else {
            currentPlayer = currentPlayer.opponent
        }
        
        return true
    }
    
    private func checkWin(for player: Player) -> Bool {
        // Check rows
        for row in 0..<3 {
            if board[row].allSatisfy({ $0 == player }) {
                return true
            }
        }
        
        // Check columns
        for col in 0..<3 {
            if (0..<3).allSatisfy({ board[$0][col] == player }) {
                return true
            }
        }
        
        // Check diagonals
        if board[0][0] == player && board[1][1] == player && board[2][2] == player {
            return true
        }
        if board[0][2] == player && board[1][1] == player && board[2][0] == player {
            return true
        }
        
        return false
    }
    
    private func isBoardFull() -> Bool {
        return board.allSatisfy { row in
            row.allSatisfy { $0 != nil }
        }
    }
    
    // Get the current board state
    func getBoard() -> [[Player?]] {
        return board
    }
    
    // Reset the game
    func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: 3), count: 3)
        currentPlayer = .x
        gameState = .inProgress
    }
} 