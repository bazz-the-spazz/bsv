# .bsv is a new data structure based on "Break Separated Values".
# It takes the data table and converts it into a long string of data).
# The original structure is described in the first few lines.
# Additionally Metadata for each column can be stored.
# write.bsv creates the datafiles. read.bsv reads them.


write.bsv <- function(x, file, description="", metadata="no.metadata", rownames=FALSE, prompt.metadata=FALSE, prompt.description=FALSE){
	# x: is the datatable to be stored
	# description: is a character (or string of characters) to describe the data. "prompt" will start asking you about the data.
	# metadata: should be a string of descriptions for each variable. Write "prompt" to be asked for each variable seperately.
	# rownames: logical for a column for rownames. Rownames might be handy when modifing the .bsv-file externally. This will not affect read.bsv (which only looks at the first column).

	# make shure these are characters
	description <- if(description=="") file else as.character(description)
	metadata <- as.character(metadata)

	# interctively ask for description when prompt.
	if(description[1]=="prompt" | prompt.description ){
		for(i in 1:as.numeric(readline("How many lines for the description of the data? "))) description[i] <- readline(paste("Description Nr.", i, ": "))
	}

	# interctively ask for metadata when prompt.
	if(metadata[1]=="prompt" | prompt.metadata) {
		metadata <- character()
		for(i in 1:ncol(x)){
			metadata[i] <- readline(paste("Describe variable ", names(x)[i]," : ", sep=" "))
			if(metadata[i]=="break") {
				metadata[i] <- "no.metadata"
				break
			}
		}
	}
	# make metadata correct length
	if(length(metadata)<ncol(x)) { # append "no.metadata" when metadata is to short
		metadata <- c(metadata, rep("no.metadata", ncol(x)-length(metadata)))
		warning("not enough Metadata supplied. Consider adding it with 'metadata='", immediate. = TRUE)}
	if(length(metadata)>ncol(x)) { # truncate when metadata is to long
		metadata <- metadata[1:ncol(x)]
		warning("too much Metadata supplied", immediate. = TRUE)}

	# Loop to bind the columns to one long string
	d<- Is <- character()
	for(i in 1:ncol(x)){
		d <- c(d, as.character(x[,i]))
		Is[i] <- is(x[,i])[1]  # note the class of each column
	}

	# connect the metadata and data
	d <- c(description, "Dimension of table (rows and columns):", dim(x),  "METADATA_for_variables",  paste(names(x), Is,  metadata, sep="__METADATA__"),
 "The Values of each cell are listed below. Above the correct dimensions of the table and the metadata of the variables are noted. Use the 'read.bsv'-command  (github.com/bazz-the-spazz/bsv) to read the table in R or reconstruct the table yourself.","START_OF_DATA",d)

	# # Optional: ad a column for rownames
	if(rownames) 	d <- cbind(d,c(rep("description", length(description)), "Dimensions", "number of rows", "number of columns", "METADATA" , rep("name, class, and metadata", ncol(x)), "", "START_OF_row_numbers", rep(rownames(x), ncol(x))))

	# write table
	write.table(d, file = file, quote = T, append = F, row.names = F, col.names = F )
}

read.bsv <- function(file, ...){
	# read a .bsv file as created by write.bsv
	# file: name of the file

	# read first column of file
	d <- as.character(read.table(file, header = F)[,1])

	# get information about structure and metadata of the table
	description <- d[1:(which(d=="Dimension of table (rows and columns):")-1)]

	nrow <- as.integer(d[which(d=="Dimension of table (rows and columns):")+1]) # number of rows
	ncol <- as.integer(d[which(d=="Dimension of table (rows and columns):")+2]) # number of columns

	x <- do.call("rbind", strsplit(d[(which(d=="METADATA_for_variables")+1):(which(d=="METADATA_for_variables")+ncol)], split = "__METADATA__")) # split up the metadata part
	names <- x[,1] # get names of columns
	Is <- x[,2]    # get class of variables
	metadata <- x[,3]# get metadata
	start <- which(d=="START_OF_DATA")+1

	# put together the dataframe and change classes
	dd <- as.data.frame(matrix(ncol = ncol, nrow = nrow))
	for(i in 1:ncol){
		dd[,i] <- d[ (start + ((i-1)*nrow)):((i*nrow)+ start -1 )]
		if(!(Is[i] %in% c("factor", "numeric", "integer", "logical"))) warning(paste("class",Is[i], "is not yet supported. add it to the function yourself! The variable", names[i], "will be added as character.", sep=" "), immediate. = TRUE) # If a class is not yet listed this warning will pop off. Consider adding the class as below.
		if(Is[i]=="factor") dd[,i] <- as.factor(dd[,i])
		if(Is[i]=="numeric") dd[,i] <- as.numeric(dd[,i])
		if(Is[i]=="integer") dd[,i] <- as.integer(dd[,i])
		if(Is[i]=="logical") dd[,i] <- as.logical(dd[,i])

	}
	names(dd) <- names # name the variables
	return(list(description=description, metadata=data.frame(variable=names, metadata), data = dd)) # Print a list with the data and metadata
}
