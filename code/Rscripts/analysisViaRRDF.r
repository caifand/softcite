library(rrdf)
library(ggplot2)
library(dplyr)

setwd("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/")

softciteData = load.rdf("data/SoftwareCitationDataset.ttl", format="TURTLE")

summarize.rdf(softciteData)
prefixes <- paste(readLines("code/Rscripts/sparql_prefixes.sparql", encoding="UTF-8"), collapse=" ")

# Sample summary statistics
no_codes_query <- paste(readLines("code/Rscripts/all_data_no_codes.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

code_matrix <- sparql.rdf(softciteData, paste(prefixes, no_codes_query, collapse=" "))

data <- data.frame(code_matrix)

data %.%
  group_by(strata) %.%
  summarise(freq=count_distinct(journal_title))

data %.% 
  group_by(journal_title) %.% 
  summarise(freq = length(unique(article))) %.% 
  arrange(desc(freq))
  
  data %.% 
    group_by(stata,journal_title) %.% 
    summarise(freq = length(unique(article))) %.% 
    arrange(desc(freq))




all_codes_query <- paste(readLines("code/Rscripts/all_codes_query.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

code_matrix <- sparql.rdf(softciteData, paste(prefixes, all_codes_query, collapse=" "))

data <- data.frame(code_matrix)

#################
#  Percent Agreement, between cgrady and jhowison as coders
#  Uses data from different files.
#################

setwd("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/")

jamesCoding = load.rdf("data/agreement_testing/Round1-SeeingMentions/CatherineCoding.ttl", format="TURTLE")

catherineCoding = load.rdf("data/agreement_testing/Round1-SeeingMentions/JamesCoding.ttl", format="TURTLE")

combindedCoding = combine.rdf(jamesCoding,catherineCoding)

summarize.rdf(combindedCoding)  # 2432 triples

combindedCoding = load.rdf("data/agreement_testing/Round1-SeeingMentions/testingMatchesQueries.ttl", format="TURTLE")

# Ok, need to get three numbers.  Both agreeing, J not C, and C not J.

# One useful format:
# URL, J, C 
# ..., coded, coded 
# ..., not-coded, coded

agreement_query <- paste(readLines("code/Rscripts/agreement_query.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

agreements <- sparql.rdf(combindedCoding, paste(prefixes, agreement_query, collapse=" "))



# Now produce a few relevant graphs.

ggplot(data, aes(x=strata,fill=code)) + geom_bar()

# Mentions by strata.

tempdata <- subset(data, code == "citec:in-text_mention")
tempdata <- droplevels(tempdata)
ggplot(tempdata, aes(x=strata)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

# Of all the mentions, which were findable, which were not?
tempdata <- subset(data, code == "citec:findable" | code == "citec:unfindable")
tempdata <- droplevels(tempdata)
ggplot(tempdata, aes(x=strata, fill=code)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

# Of all the mentions, which were 
tempdata <- subset(data, code == "citec:identifiable" | code == "citec:unidentifiable")
tempdata <- droplevels(tempdata)
ggplot(tempdata, aes(x=strata, fill=code)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

tempdata <- subset(data, code == "citec:findable_version" | code == "citec:unfindable_version")
tempdata <- droplevels(tempdata)
ggplot(tempdata, aes(x=strata, fill=code)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

tempdata <- subset(data, code == "citec:permission_modify" | code == "citec:prohibited_modify")
tempdata <- droplevels(tempdata)
ggplot(tempdata, aes(x=strata, fill=code)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

tempdata <- subset(data, code == "citec:access_free" | code == "citec:access_purchase" | code == "citec:no_access")
tempdata$code <- ordered(tempdata$code, levels=c("citec:no_access", "citec:access_free", "citec:access_purchase"))
ggplot(tempdata, aes(x=strata, fill=code)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

tempdata <- subset(data, code == "citec:source_available" | code == "citec:source_unavailable")
tempdata$code <- ordered(tempdata$code, levels=c("citec:source_available", "citec:source_unavailable"))
ggplot(tempdata, aes(x=strata, fill=code)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

