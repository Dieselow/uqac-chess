package edu.uqac.aop.chess.aspects;

import edu.uqac.aop.chess.Board;
import edu.uqac.aop.chess.Spot;
import edu.uqac.aop.chess.agent.Move;
import edu.uqac.aop.chess.agent.Player;
import edu.uqac.aop.chess.piece.Knight;
import edu.uqac.aop.chess.piece.Piece;

public aspect MoveValidatorAspect {

    /**
     * Check if Move is correct before being constructed
     *
     * @return boolean
     */
   /** boolean before(Move pieceMove, int xI, int yI, int xF, int yF):
            call(Move edu.uqac.aop.chess.agent.Move+.Move) && target(pieceMove) && args(xI,yI,xF,yF){
        if (xI < 0 || yI < 0) return false;
        return xF <= Board.SIZE - 1 && yF <= Board.SIZE - 1;
    }**/
   boolean around(Move pieceMove):
            execution(edu.uqac.aop.chess.agent.Move+.new(..)) && target(pieceMove) && args(xI,yI,xF,yF){
        System.out.println(thisJoinPointStaticPart);
        if (pieceMove.xI < 0 || pieceMove.yI < 0) return false;
        return pieceMove.xF <= Board.SIZE - 1 && pieceMove.yF <= Board.SIZE - 1;
    }

    boolean around(Player player, Move pieceMove):
            call(boolean edu.uqac.aop.chess.agent.Player.makeMove(Move))
                    && target(player) && args(pieceMove){
        Spot[][] grid = player.getPlayGround().getGrid();
        if (checkPieceOwnership(player,pieceMove)
                && checkLegalPieceMove(this.getPieceFromBoard(grid,pieceMove.xI,pieceMove.yI),pieceMove)
                && checkOffensiveMove(grid,pieceMove) && checkPassedPiece(grid,pieceMove)){
            return true;
        }
        return false;
    }

    private boolean checkPieceOwnership(Player player, Move pieceMove) {
        return player.getColor() == this.getMovePieceColor(player.getPlayGround().getGrid(), pieceMove);
    }

    private int getMovePieceColor(Spot[][] grid, Move mv) {
        Piece targetPiece = this.getPieceFromBoard(grid,mv.xI, mv.yI);
        if (targetPiece == null){
            return -1;
        }
        return targetPiece.getPlayer();
    }
    private boolean checkLegalPieceMove(Piece piece,Move attemptedMove){
        return piece.isMoveLegal(attemptedMove);
    }

    private Piece getPieceFromBoard(Spot[][] grid, int x , int y){

        if (!grid[x][y].isOccupied()){
            return null;
        }
        return grid[x][y].getPiece();
    }

    private boolean checkOffensiveMove(Spot[][] grid, Move pieceMove){
        Piece movedPiece = this.getPieceFromBoard(grid, pieceMove.xI,pieceMove.yI);
        Piece targetedPiece = this.getPieceFromBoard(grid,pieceMove.xF,pieceMove.yF);
        return targetedPiece == null || targetedPiece.getPlayer() != movedPiece.getPlayer();
    }

    private boolean checkPassedPiece(Spot[][] grid, Move playerMove){
        if (this.getPieceFromBoard(grid,playerMove.xI, playerMove.yI).getClass() == Knight.class){
            return true;
        }
        if (playerMove.xI == playerMove.xF){
            return verticalMove(grid,playerMove);
        }
        if (playerMove.yI == playerMove.yF){
            return horizontalMove(grid,playerMove);
        }
        return diagonalMove(grid, playerMove);
    }
    private boolean horizontalMove(Spot[][] grid, Move playerMove){
        if (playerMove.xI < playerMove.xF){
            for (int i= playerMove.xI+1; i< playerMove.xF -1;i++){
                if (grid[i][playerMove.yI].isOccupied()){
                    return false;
                }
            }
            return true;
        }
        for (int i= playerMove.xI- 1; i > playerMove.xF-1;i--){
            if (grid[i][playerMove.yI].isOccupied()){
                return false;
            }
        }
        return true;
    }

    private boolean verticalMove(Spot[][] grid, Move playerMove){
        if (playerMove.yI < playerMove.yF){
            for (int i= playerMove.yI + 1; i< playerMove.yF -1;i++){
                if (grid[playerMove.xI][i].isOccupied()){
                    return false;
                }
            }
            return true;
        }
        for (int i= playerMove.yI-1; i > playerMove.yF-1;i--){
            if (grid[playerMove.xI][i].isOccupied()){
                return false;
            }
        }
        return true;
    }

    private boolean diagonalMove(Spot[][] grid, Move playerMove){
        int initialX = playerMove.xI < playerMove.xF ? playerMove.xI + 1 : playerMove.xF -1;
        int finalX = playerMove.xF < playerMove.xI ? playerMove.xI +1 :playerMove.xF -1;
        int initialY = playerMove.yI < playerMove.yF ? playerMove.yI + 1 : playerMove.yF -1;
        int finalY = playerMove.yF < playerMove.yI ? playerMove.yI +1 :playerMove.yF -1;
        while (initialX <  finalX || initialY < finalY){
            if (initialX < finalX){
                initialX++;
            }
            if (initialY < finalY){
                initialY++;
            }
            if (grid[initialX][initialY].isOccupied()){
                return false;
            }
        }
        return true;
    }

}
