package org.ak2.fb2.library.commands;

import org.ak2.fb2.library.exceptions.LibraryException;

public interface ICommand {

    String PARAM_INPUT = "input";

    String PARAM_OUTPUT = "output";

    String PARAM_OUTFORMAT = "outformat";

    String PARAM_OUTPATH = "outpath";

    String PARAM_DEPTH = "depth";

    String PARAM_DISTANCE = "distance";

    String PARAM_INC_FILES = "distance";

    String PARAM_DELETE = "delete";

    String getName();

    String getDescription();
    
    ICommandParameter[] getParameters();
    
    void execute(CommandArgs args) throws LibraryException;

}
