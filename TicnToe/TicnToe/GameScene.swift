//
//  GameScene.swift
//  TicnToe
//
//  Created by Subham Das on 31/12/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var game = TicTacToeGame()
    private var gridNodes: [[SKShapeNode]] = []
    private var boardNode: SKShapeNode!
    private var statusLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        setupGame()
    }
    
    private func setupGame() {
        // Create board background
        boardNode = SKShapeNode(rectOf: CGSize(width: 300, height: 300))
        boardNode.fillColor = .white
        boardNode.strokeColor = .black
        boardNode.position = CGPoint(x: frame.midX, y: frame.midY)
        boardNode.zPosition = 0
        addChild(boardNode)
        
        // Create status label with better positioning and style
        statusLabel = SKLabelNode(text: "Player X's Turn")
        statusLabel.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        statusLabel.fontSize = 32
        statusLabel.fontName = "AvenirNext-Bold"
        statusLabel.fontColor = .black
        statusLabel.zPosition = 1
        addChild(statusLabel)
        
        // Create grid cells with proper spacing
        let cellSize: CGFloat = 90
        let spacing: CGFloat = 100
        let startX = frame.midX - spacing
        let startY = frame.midY + spacing
        
        gridNodes.removeAll() // Clear existing grid nodes
        
        for row in 0..<3 {
            var rowNodes: [SKShapeNode] = []
            for col in 0..<3 {
                let cell = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize))
                cell.fillColor = .white
                cell.strokeColor = .black
                cell.lineWidth = 2
                
                let x = startX + CGFloat(col) * spacing
                let y = startY - CGFloat(row) * spacing
                cell.position = CGPoint(x: x, y: y)
                
                cell.name = "\(row),\(col)"
                cell.zPosition = 1
                addChild(cell)
                rowNodes.append(cell)
            }
            gridNodes.append(rowNodes)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if we hit any node at the touch location
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "resetButton" {
                resetGame()
                return
            }
            
            // Check if the node name contains coordinates
            if let name = node.name,
               let coordinates = parseCoordinates(from: name) {
                let (row, col) = coordinates
                handleMove(row: row, col: col)
                return
            }
        }
    }
    
    private func parseCoordinates(from name: String) -> (Int, Int)? {
        let components = name.split(separator: ",")
        guard components.count == 2,
              let row = Int(components[0]),
              let col = Int(components[1]) else {
            return nil
        }
        return (row, col)
    }
    
    private func updateStatusLabel(with text: String) {
        // Remove existing status label animation if any
        statusLabel.removeAllActions()
        
        // Update text
        statusLabel.text = text
        
        // Add emphasis animation for win/draw messages
        if text.contains("Wins!") || text.contains("Draw!") {
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
            let sequence = SKAction.sequence([scaleUp, scaleDown])
            statusLabel.run(sequence)
            
            // Change color for win/draw messages
            statusLabel.fontColor = text.contains("Wins!") ? .green : .blue
        } else {
            // Reset color for normal turn messages
            statusLabel.fontColor = .black
        }
    }
    
    private func handleMove(row: Int, col: Int) {
        // Store the current player before making the move
        let currentPlayer = game.currentPlayer
        
        // Only proceed if the move is valid
        guard game.makeMove(row: row, col: col) else { return }
        
        // Add the symbol for the player who just moved
        let symbol = SKLabelNode(text: currentPlayer == .x ? "X" : "O")
        symbol.fontSize = 60
        symbol.fontName = "AvenirNext-Bold"
        symbol.fontColor = .black
        
        // Get the cell position from gridNodes
        let cell = gridNodes[row][col]
        symbol.position = cell.position
        
        symbol.verticalAlignmentMode = .center
        symbol.horizontalAlignmentMode = .center
        symbol.zPosition = 2 // Make sure it's above the grid
        
        // Add a small scale animation when placing the symbol
        symbol.setScale(0.5)
        let scaleAction = SKAction.scale(to: 1.0, duration: 0.2)
        symbol.run(scaleAction)
        
        addChild(symbol)
        
        // Update game status with animation
        switch game.gameState {
        case .inProgress:
            updateStatusLabel(with: "Player \(game.currentPlayer == .x ? "X" : "O")'s Turn")
        case .won(let player):
            updateStatusLabel(with: "Player \(player == .x ? "X" : "O") Wins!")
            addResetButton()
        case .draw:
            updateStatusLabel(with: "It's a Draw!")
            addResetButton()
        }
    }
    
    private func addResetButton() {
        let resetButton = SKShapeNode(rectOf: CGSize(width: 120, height: 40))
        resetButton.fillColor = .blue
        resetButton.strokeColor = .clear
        resetButton.position = CGPoint(x: frame.midX, y: frame.midY - 200) // Moved lower
        resetButton.name = "resetButton"
        
        let resetLabel = SKLabelNode(text: "Reset Game")
        resetLabel.fontSize = 20
        resetLabel.fontName = "AvenirNext-Bold"
        resetLabel.fontColor = .white
        resetLabel.verticalAlignmentMode = .center
        
        resetButton.addChild(resetLabel)
        addChild(resetButton)
    }
    
    private func resetGame() {
        game.resetGame()
        removeAllChildren()
        setupGame()
    }
}
