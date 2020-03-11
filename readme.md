# bsv
.bsv is a new data structure based on "Break Separated Values".
It takes the data table and converts it into a long string of data.
The original structure is described in the first few lines.
Additionally Metadata for each column is stored.
write.bsv creates the datafiles. read.bsv reads them.

## Example 

'write.bsv(x = data.frame(a=1:10, b=21:30, c=rep("a",10)), filename = "test.bsv", description=c("Titel", "subtext"), metadata =c("X", "Y", "Z"), rownames = FALSE)'

'dx <- read.bsv(file = "test.bsv")'

'dx$metadata'

'str(dx$data)'

'dx$data'
