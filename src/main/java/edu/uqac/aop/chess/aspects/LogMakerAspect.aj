package edu.uqac.aop.chess.aspects;

import edu.uqac.aop.chess.Board;
import edu.uqac.aop.chess.agent.Move;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

public aspect LogMakerAspect {

    private static File filePath;

    after(): execution(void *.setupChessBoard()) {
        initFile();
    }

    after(Board board, Move mv): execution(void *.movePiece(Move)) && target(board) && args(mv) {
        writeInFile(board.toString() + mv.toString() + "\n\n");
    }

    private void initFile() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss");
        String directoryPath = "output/";
        String fileName = "ChessGameLog_" + sdf.format(new Date()) + ".log";

        File directory = new File(directoryPath);

        if (! directory.exists()) {
            directory.mkdir();
        }

        filePath = new File(directoryPath + fileName);

        try {
            if (!filePath.createNewFile()) { filePath = null; }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void writeInFile(String text) {
        if (filePath != null) {
            try {
                FileWriter fileWriter = new FileWriter(filePath, true);
                fileWriter.write(text);
                fileWriter.close();

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

}
