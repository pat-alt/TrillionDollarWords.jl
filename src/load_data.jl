using CSV
using DataFrames
using LazyArtifacts

"""
    load_all_sentences()

Load the dataset with all sentences from the artifact. This is the complete dataset with sentences from press conferences, meeting minutes, and speeches. 

- The `doc_id` column is the unique identifier of the document.
- The `date` column is the date of the event.
- The `event_type` column is the type of event (meeting minutes, speech, or press conference).
- The labels in `label` are predicted by the model proposed in the paper.

> We use the RoBERTa-large model finetuned on the combined data to label all the filtered sentences in the meeting minutes, speeches, and press conferences.

- The `sentence` column is the sentence itself. 
- The `score` column is the softmax probability of the label.
- The `speaker` column is the speaker of the sentence (if applicable).
"""
load_all_sentences() = CSV.read(joinpath(artifact"clean_data","all_sentences.csv"), DataFrame)

"""
    load_training_sentences()

Load the dataset with training sentences from the artifact. This is a combined dataset containing sentences from press conferences, meeting minutes, and speeches.

- The `sentence` column is the sentence itself. 
- The `year` column is the year of the event.
- The labels in `label` are the manually annotated labels from the paper.
- The `seed` column is the seed that was used to split the data into train and test set in the paper. 
- The `sentence_splitting` column indicates if the sentence was split or not (see the paper for details).
- The `event_type` column is the type of event (meeting minutes, speech, or press conference).
- The `split` column indicates if the sentence is in the train or test set.

"""
load_training_sentences() = CSV.read(joinpath(artifact"clean_data","training_sentences.csv"), DataFrame)

"""
    load_cpi_data()

Load the CPI data from the artifact. This is the CPI data used in the paper.

- The `date` column is the date of the event.
- The `value` columns is the value of the market indicator (CPI, PPI, or UST).
- The `indicator` column is the market indicator (CPI, PPI, or UST).
"""
load_cpi_data() = CSV.read(joinpath(artifact"clean_data","market_data/cpi.csv"), DataFrame)

"""
    load_ppi_data()

Load the PPI data from the artifact. This is the PPI data used in the paper.

- The `date` column is the date of the event.
- The `value` columns is the value of the market indicator (CPI, PPI, or UST).
- The `indicator` column is the market indicator (CPI, PPI, or UST).
"""
load_ppi_data() = CSV.read(joinpath(artifact"clean_data", "market_data/ppi.csv"), DataFrame)

"""
    load_ust_data()

Load the UST (treasury yields) data from the artifact. This is the UST data used in the paper.

- The `date` column is the date of the event.
- The `value` columns is the value of the market indicator (CPI, PPI, or UST).
- The `indicator` column is the market indicator (CPI, PPI, or UST).
- The `maturity` column is the maturity of the UST (if applicable).
"""
load_ust_data() = CSV.read(joinpath(artifact"clean_data", "market_data/ust.csv"), DataFrame)

"""
    load_market_data()

Load the combined market data from the artifact. This dataset combines the CPI, PPI and UST data used in the paper.

- The `date` column is the date of the event.
- The `value` columns is the value of the market indicator (CPI, PPI, or UST).
- The `indicator` column is the market indicator (CPI, PPI, or UST).
- The `maturity` column is the maturity of the UST (if applicable).
"""
load_market_data() = CSV.read(joinpath(artifact"clean_data", "market_data/combined.csv"), DataFrame)

"""
    load_all_data()

Load the combined dataset from the artifact. This dataset combines all sentences and the market data used in the paper.

- The `doc_id` column is the unique identifier of the document.
- The `date` column is the date of the event.
- The `event_type` column is the type of event (meeting minutes, speech, or press conference).
- The labels in `label` are predicted by the model proposed in the paper.

> We use the RoBERTa-large model finetuned on the combined data to label all the filtered sentences in the meeting minutes, speeches, and press conferences.

- The `sentence` column is the sentence itself. 
- The `score` column is the softmax probability of the label.
- The `speaker` column is the speaker of the sentence (if applicable).
- The `value` columns is the value of the market indicator (CPI, PPI, or UST).
- The `indicator` column is the market indicator (CPI, PPI, or UST).
- The `maturity` column is the maturity of the UST (if applicable).

"""
load_all_data() = CSV.read(joinpath(artifact"clean_data", "all_data.csv"), DataFrame)