# .bsv is a new data structure based on "Break Separated Values".
# It takes the data table and converts it into a long string of data).
# The original structure is described in the first few lines.
# Additionally Metadata for each column can be stored.
# write.bsv creates the datafiles. read.bsv reads them.


write.bsv <- function(x, file, description, metadata="no.metadata", Rownames=FALSE, prompt.metadata=FALSE, prompt.description=FALSE,  fileEncoding = "UTF-8" ){
  # x: is the datatable to be stored
  # description: is a character (or string of characters) to describe the data. "prompt" will start asking you about the data.
  # metadata: should be a string of descriptions for each variable. Write "prompt" to be asked for each variable seperately.
  # rownames: logical for a column for rownames. Rownames might be handy when modifing the .bsv-file externally. This will not affect read.bsv (which only looks at the first column).
  
  # dimensions
  nr <- nrow(x)
  nc <- ncol(x)
  
  # make shure these are characters
  if(missing(description)) description <- file else description <- as.character(description)
  metadata <- as.character(metadata)
  
  # interctively ask for description when prompt.
  if(description[1]=="prompt" | prompt.description ){
    for(i in 1:as.numeric(readline("How many lines for the description of the data? "))) description[i] <- readline(paste("Description Nr.", i, ": "))
  }
  

  # interctively ask for metadata when prompt.
  if(metadata[1]=="prompt" | prompt.metadata) {
    metadata <- character()
    for(i in 1:nc){
      metadata[i] <- readline(paste("Describe variable ", names(x)[i]," : ", sep=" "))
      if(metadata[i]=="break") {
        metadata[i] <- "no.metadata"
        break
      }
    }
  }
  # make metadata correct length
  if(length(metadata)<nc) { # append "no.metadata" when metadata is to short
    metadata <- c(metadata, rep("no.metadata", ncol(x)-length(metadata)))
    warning("not enough Metadata supplied. Consider adding it with 'metadata='", immediate. = TRUE)}
  if(length(metadata)>nc) { # truncate when metadata is to long
    metadata <- metadata[1:nc]
    warning("too much Metadata supplied", immediate. = TRUE)}
  
  

  
  # # Optional: ad a column for rownames
  if(Rownames){
    nc <- nc+1
    metadata <- c( metadata, "Rownames")
    x$Rownames <- rownames(x)
  }
  
  # Loop to bind the columns to one long string
  d<- Is <- character()
  for(i in 1:ncol(x)){
    d <- c(d, as.character(x[,i]))
    Is[i] <- is(x[,i])[1]  # note the class of each column
  }


  
  # connect the metadata and data
  d <- c(paste("fileEncoding", fileEncoding), description,  "Dimension of table (rows and columns):", nr, nc,  "METADATA_for_variables",  paste(names(x), Is,  metadata, sep="__METADATA__"),
         "The Values of each cell are listed below. Above the correct dimensions of the table and the metadata of the variables are noted. Use the 'read.bsv'-command  (github.com/bazz-the-spazz/bsv) to read the table in R or reconstruct the table yourself.","START_OF_DATA",d)
  
  # write table
  write.table(d, file = file, quote = F, append = F, row.names = F, col.names = F, fileEncoding = fileEncoding )
}



read.bsv <- function(file, fileEncoding, ...){
  # read a .bsv file as created by write.bsv
  # file: name of the file
  
  # check for fileEncoding
  if(missing(fileEncoding)){
    fileEncoding <- unlist(
      strsplit(readLines(file, n=1 ), " ")
    )[2]
  }
  
  # read first column of file
  d <- readLines(file, encoding = fileEncoding)
  
  # Change "NA" to NA
  d[d=="NA"] <- NA
  
  # get information about structure and metadata of the table
  description <- d[1:(which(d=="Dimension of table (rows and columns):")-1)]
  
  nr <- as.integer(d[which(d=="Dimension of table (rows and columns):")+1]) # number of rows
  nc <- as.integer(d[which(d=="Dimension of table (rows and columns):")+2]) # number of columns
  
  x <- do.call("rbind", strsplit(d[(which(d=="METADATA_for_variables")+1):(which(d=="METADATA_for_variables")+nc)], split = "__METADATA__")) # split up the metadata part
  names <- x[,1] # get names of columns
  Is <- x[,2]    # get class of variables
  metadata <- x[,3]# get metadata
  metadata <- data.frame(variable=names, metadata) # create metadata table
  start <- which(d=="START_OF_DATA")+1
  
  # put together the dataframe and change classes
  dd <- as.data.frame(matrix(ncol = nc, nrow = nr))
  for(i in 1:nc){
    dd[,i] <- d[ (start + ((i-1)*nr)):((i*nr)+ start -1 )]
    if(!(Is[i] %in% c("factor", "numeric", "integer", "logical", "character"))) warning(paste("class",Is[i], "is not yet supported. add it to the function yourself! The variable", names[i], "will be added as character.", sep=" "), immediate. = TRUE) # If a class is not yet listed this warning will pop off. Consider adding the class as below.
    if(Is[i]=="factor") dd[,i] <- as.factor(dd[,i])
    if(Is[i]=="numeric") dd[,i] <- as.numeric(dd[,i])
    if(Is[i]=="integer") dd[,i] <- as.integer(dd[,i])
    if(Is[i]=="logical") dd[,i] <- as.logical(dd[,i])
    if(Is[i]=="character") dd[,i] <- as.character(dd[,i])
    
  }
  names(dd) <- names # name the variables
  
  
  # are there rownames?
  if(metadata[nc,1]=="Rownames"){
    rownames(dd) <- dd$Rownames # name the rows
    dd$Rownames <- NULL         # delete column Rownames
    metadata <- metadata[-nc,]  # remove metadata
  }
  
  return(list(description=description, metadata=metadata, data = dd)) # Print a list with the data and metadata
}
