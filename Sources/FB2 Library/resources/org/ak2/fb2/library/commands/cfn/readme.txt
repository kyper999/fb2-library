convert file names. 
This command renames all files from input folder into output folder.
The following options are supported:
        -input  <original book file or folder> - input file or folder
        -output <target folder> - folder to store renamed book
        -outpath <output path type> - output path type. The following are supported:
                Simple   - Book will be saved into the output folder indirectly
                Standard - Book will be save into an author/sequence sub-folder in the output folder.
                Library - Book will be save into an a/author/sequence sub-folder in the output folder.
        -outformat <output book format> - output book format. The following are supported:
                FB2 - uncompressed fb2 book
                ZIP - fb2 book in a separated zip archive
