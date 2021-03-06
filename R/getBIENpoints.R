library(BIEN)
library(lubridate)

#' @title Download occurrence points from BIEN
#'
#' @description Downloads occurrence points and useful related information for processing within other occCite functions
#'
#' @param taxon A single plant species or vector of plant species
#'
#' @return A list containing (1) a dataframe of occurrence data; (2) a list containing: i notes on usage, ii bibtex citations, and iii aknowledgement information.
#'
#' @examples
#' getBIENpoints(taxon="Acer rubrum");
#'
#' @export
getBIENpoints<-function(taxon){
  occs<-BIEN::BIEN_occurrence_species(species = taxon,cultivated = T,
                                  only.new.world = F, native.status = T,
                                  collection.info = T,natives.only = F);

  occs<-occs[which(!is.na(occs$latitude) & !is.na(occs$longitude)),];

  #Fixing dates
  occs <-occs[which(!is.na(occs$date_collected)),];
  occs$date_collected <- lubridate::ymd(occs$date_collected);
  yearCollected <- as.numeric(format(occs$date_collected, format = "%Y"))
  monthCollected <- as.numeric(format(occs$date_collected, format = "%m"))
  dayCollected <- as.numeric(format(occs$date_collected, format = "%d"))
  occs <- cbind(occs, dayCollected, monthCollected, yearCollected)

  #Tidying up data table
  outdata<-occs[c('scrubbed_species_binomial',
                  'longitude','latitude','dayCollected', 'monthCollected',
                  'yearCollected', 'dataset','datasource_id')];
  dataService <- rep("BIEN", nrow(outdata));
  outdata <- cbind(outdata, dataService);
  outdata <- as.data.frame(outdata);
  colnames(outdata) <- c("name", "longitude",
                         "latitude", "day", "month",
                         "year", "Dataset",
                         "DatasetKey", "DataService");

  #Get metadata
  occMetadata <- BIEN::BIEN_metadata_citation(occs);
  occMetadata$license<-"CC BY-NC-ND";

  #Package it all up
  outlist<-list();
  outlist[[1]]<-outdata;
  outlist[[2]]<-occMetadata;
  names(outlist) <- c("OccurrenceTable", "Metadata")

  return(outlist);
}
