



.plot_diagram <- function() {

  read_nodes <- function(database_dir, tables) {
    nodes <- ""
    for (table in tables) {
      if (file.exists(paste0(database_dir,table,'.RDS'))) {
        dataset <- readRDS(paste0(database_dir,table,'.RDS'))
        dataset_names <- names(dataset)
        dataset_class <- sapply(dataset, function(x) class(x))
        atributes <- paste0(dataset_names," : ",dataset_class,'\\n', collapse = "")
        rows <- nrow(dataset)
        cols <- ncol(dataset)
        saved_file <- T
      } else {
        saved_file <- F
      }

      nodes <- paste0(nodes,
                      table,"[",
                      " fillcolor=",ifelse(saved_file,"cadetblue1","gray"),
                      " label = '{",
                      table,ifelse(saved_file,paste0("|nrow: ",rows," ncol: ",cols),""),
                      "}']")
    }
    return(nodes)
  }

  nodes <- read_nodes(.self$path_to, .self$tables)

  edges <- lapply(seq_along(.self$relations), function(v) paste0(names(.self$relations)[[v]], '->' ,.self$relations[v]))

  edges <- paste0(edges, collapse = ' ')

  graph <- DiagrammeR::grViz(paste0('digraph G {
    fontname = "Bitstream Vera Sans"
    fontsize = 6
    node [
      fontname = "Bitstream Vera Sans"
      fontsize = 6
      margin = "0.2,0.05"
      shape = "record"
      style = "filled"
      fillcolor = "cadetblue1"
    ]
    edge [
      arrowtail = "empty"
      dir=back
    ]
    ',
    nodes,
    edges,
  ' }'),width = "50%",height = "50%")
  graph
}

##### database ####


.read <- function(dataset_name) {
  # read rds
  if (length(.self$tables) > 0){
    if (dataset_name %in% .self$tables){
      if(file.exists(paste0(.self$path_to, dataset_name, ".RDS"))){
        return(readRDS(paste0(.self$path_to, dataset_name, ".RDS")))
      } else {
        stop("Not saved data, only documented table")
      }
    }
  }
  stop("dataset not found")
}

.save <- function(dataset, parent_name = c(),save_file = TRUE) {
  table_name <- deparse(substitute(dataset))
  if(length(parent_name) > 0){
    if(!all(parent_name %in% tables)){
      stop("undefined parent name in database")
    }
  }

  if(save_file){
    saveRDS(dataset, paste0(.self$path_to,table_name,".RDS"))
  }
  if (length(parent_name) > 0) {
    .self$relations[table_name] <- paste0("{ ",paste0(parent_name, collapse = ' '), " }")
  }

  if (length(.self$tables) > 0){
    if (table_name %in% .self$tables) {
      return(TRUE)
    }
  }
  .self$tables <- c(tables, table_name)
  saveRDS(.self, file = paste0(database$path_to,'/database'))
  return(TRUE)
}

.delete <- function(dataset_name) {

  if (length(.self$tables) > 0){
    if (!dataset_name %in% .self$tables){
      stop('dataset not found')
    }
  }

  for (relation in .self$relations) {
    if(grepl(paste0(' ',dataset_name,' '),relation)){
      stop(paste("removing this table will affect these tables:",relation, ",please save then with another or none parent", collapse = " "))
    }
  }
  .self$tables <- .self$tables[!dataset_name == .self$tables]
  if(!is.null(.self$relations[dataset_name])){
    .self$relations[dataset_name] <- NULL
  }
  if(file.exists(paste0(.self$path_to,dataset_name, ".RDS"))){
    file.remove(paste0(.self$path_to,dataset_name,".RDS"))
  }
  return(TRUE)
}


.database_obj <- setRefClass(
  Class = 'database',
    fields = list(path_to = 'character', tables = 'character', relations = 'list'),
    methods = list(
      initialize=function(path_to = NA_character_, ...) {
        callSuper( ... )
        .self$path_to <- path_to
      },
      update_obj=function(obj) {
        callSuoer(obj)
      },
      save=.save,
      read=.read,
      delete=.delete,
      plot_diagram=.plot_diagram
    )
  )

# create file indicating data diretory

init_database <- function(path_to) {
  if(file.exists(paste0(path_to, "/database"))){
    obj <- readRDS(paste0(path_to, "/database"))
    obj <- .database_obj$new(path_to, obj)
    return(obj)
  } else {
    database <- .database_obj$new(path_to = path_to)
    saveRDS(database, file = paste0(database$path_to,'/database'))
  }
  return(database)
}
