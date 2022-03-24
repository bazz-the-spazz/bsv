bsv

.bsv is a new data structure based on "Break Separated Values".
It takes the data table and converts it into a long string of data. 

The data and original structure is described in the first few lines. 
Additionally Metadata for each column is stored.
write.bsv() creates the datafiles. read.bsv reads them.

Advantages:

- easy readable by machines and humans
- Never again problems with uncertain separation values between cells
- No additional files that describe the metadata. Everything is included in one accessible file
- class of variable is preserved (unlike other text based files)
- Future-proof. Even if the read.bsv function is lost over time its easy to read the file.



Arguments of write.bsv()

- x=:  Name of the dataframe

- file=: Name of the file to be written
- description=: Character string describing the data in general. Can be of length zero to infinity
- metadata=: Character string describing each variable. Should be the same length as the number of columns in the dataframe
- Rownames=: logical (TRUE/FALSE) . Should the rownames be included
- prompt.metadata=: Ask for a description of each variable.
- prompt.description=: Ask for a general description
- fileEncoding=: specifiy your encoding. Standard is "UTF-8"



Arguments of read.bsv()

- file=:  name of the file 
- fileEncoding:  if known: specifiy your encoding



Example 

write.bsv(x = data.frame(a=1:10, b=21:30, c=rep("a",10)), file = "test.bsv", description=c("Titel", "subtext"), metadata =c("X", "Y", "Z"), Rownames = FALSE)

dx <- read.bsv(file = "test.bsv")

dx$description

dx$metadata

str(dx$data)

dx$data


