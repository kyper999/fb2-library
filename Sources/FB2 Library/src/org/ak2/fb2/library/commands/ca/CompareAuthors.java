package org.ak2.fb2.library.commands.ca;

import java.io.File;
import java.io.FileFilter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashSet;
import java.util.Set;
import java.util.TreeSet;

import org.ak2.fb2.library.commands.AbstractCommand;
import org.ak2.fb2.library.commands.CommandArgs;
import org.ak2.fb2.library.commands.ICommandParameter;
import org.ak2.fb2.library.commands.parameters.BaseParameter;
import org.ak2.fb2.library.commands.parameters.BoolParameter;
import org.ak2.fb2.library.commands.parameters.FileSystemParameter;
import org.ak2.fb2.library.exceptions.BadCmdArguments;
import org.ak2.fb2.library.exceptions.LibraryException;
import org.ak2.utils.LengthUtils;
import org.ak2.utils.csv.CsvBuilder;
import org.ak2.utils.files.FolderScanner;
import org.ak2.utils.jlog.JLogLevel;
import org.ak2.utils.jlog.JLogMessage;

public class CompareAuthors extends AbstractCommand {

    private static final JLogMessage MSG_FOUND_CLUSTERS = new JLogMessage(JLogLevel.INFO, "The following clusters are found:\n{0}");

    private static final JLogMessage MSG_SCAN = new JLogMessage(JLogLevel.INFO, "Scan folders:");

    private static final JLogMessage MSG_CHECK = new JLogMessage(JLogLevel.INFO, "Check authors:");

    private static final JLogMessage MSG_CLUSTERS = new JLogMessage(JLogLevel.INFO, "Printing clusters:");

    private static final ICommandParameter[] PARAMS = {
    /** -input <library folder> - library folder */
    new FileSystemParameter(PARAM_INPUT, "library folder", true, false),
    /** -output <target file> - file with list of similar author name */
    new FileSystemParameter(PARAM_OUTPUT, "file with list of similar author name", false, true),
    /** -depth <depth> - search depth (default 0) */
    new BaseParameter(PARAM_DEPTH, "search depth", "0"),
    /** -distance <distance> - Levenstein distance (default 1) */
    new BaseParameter(PARAM_DISTANCE, "Levenstein distance", "1"),
    /** -include-files <true|false> - show files for authors included into a cluster */
    new BoolParameter("include-files", "show files for authors included into a cluster", false), };

    public CompareAuthors() {
        super("ca");
    }

    /**
     * @see org.ak2.fb2.library.commands.ICommand#getParameters()
     */
    @Override
    public ICommandParameter[] getParameters() {
        return PARAMS;
    }

    @Override
    public void execute(final CommandArgs args) throws LibraryException {
        MSG_ARGS.log(this.getClass().getSimpleName(), args);

        // parsing parameters
        final String inputFolder = args.getValue(PARAM_INPUT);
        final String outputFile = args.getValue(PARAM_OUTPUT);
        final int depth = args.getValue(PARAM_DEPTH, 0);
        final int distance = args.getValue(PARAM_DISTANCE, 1);
        final boolean includeFiles = args.getValue(PARAM_INC_FILES, false);

        if (LengthUtils.isEmpty(inputFolder)) {
            throw new BadCmdArguments("Input folder is missing.", true);
        }

        if (LengthUtils.isEmpty(outputFile)) {
            throw new BadCmdArguments("Output file is missing.", true);
        }

        final File folder = new File(inputFolder);
        if (!folder.isDirectory()) {
            throw new BadCmdArguments("Input folder is invalid.");
        }

        logBoldLine();
        MSG_INFO_VALUE.log("Processing folder ", inputFolder);
        MSG_INFO_VALUE.log("Output file       ", outputFile);
        MSG_INFO_VALUE.log("Scanning depth    ", depth);
        MSG_INFO_VALUE.log("Comparing distance", distance);
        MSG_INFO_VALUE.log("Include files     ", includeFiles);
        logBoldLine();

        MSG_SCAN.log();
        logBoldLine(JLogLevel.DEBUG);
        final Author[] authors = getAuthors(folder, depth);

        MSG_CHECK.log();
        logBoldLine(JLogLevel.DEBUG);
        Clusters clusters = new Clusters(authors, distance);

        MSG_CLUSTERS.log();
        logBoldLine(JLogLevel.INFO);

        final CsvBuilder buf = new CsvBuilder();

        for (final Set<Author> cluster : clusters.getClusters()) {
            Set<String> commonFiles = null;
            if (includeFiles) {
                for (Author author : cluster) {
                    Set<String> files = author.getFiles();
                    if (commonFiles == null) {
                        commonFiles = new HashSet<String>(files);
                    } else {
                        commonFiles.retainAll(files);
                    }
                }
            }

            for (Author author : cluster) {
                final File authorFolder = author.getFolder();
                buf.add(author.getName(), authorFolder.getAbsolutePath());
                buf.eol();
                if (includeFiles) {
                    Set<String> files = author.getFiles();
                    for (String file : files) {
                        buf.add("", "", commonFiles.contains(file) ? "\"=\"" : "\"+\"", file).eol();
                    }
                }
            }
            buf.eol();
        }

        try {
            PrintWriter out = new PrintWriter(new FileWriter(outputFile));
            String str = buf.toString();
            MSG_FOUND_CLUSTERS.log(str);
            out.print(str);
            try {
                out.close();
            } catch (Exception ex) {
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }

    private Author[] getAuthors(final File folder, final int depth) {
        final Set<Author> authors = new TreeSet<Author>();
        FolderScanner.enumerateDepth(folder, null, new FileFilter() {
            @Override
            public boolean accept(final File f) {
                authors.add(new Author(f));
                return true;
            }
        }, depth, Math.max(0, depth - 1));

        return authors.toArray(new Author[authors.size()]);
    }
}
