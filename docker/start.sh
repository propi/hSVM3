#!/bin/bash

function dexists(dataset) {
  if [ ! -f "$dataset" ]; then
    echo "Dataset $dataset not found!"
    exit 1
  fi
}

PARAMETERS_TEMPLATE=/root/data/templates/parameters-hSVM3.txt
PARAMETERS=/root/hSVM3/parameters-hSVM3.txt
STI=1
LANGUAGE=
VERSION=

for i in "$@"
do
case $i in
    -v=*)
    VERSION="${i#*=}"
    shift
    ;;
    -l=*)
    LANGUAGE="${i#*=}"
    shift
    ;;
    *)
    #unknown option
    ;;
esac
done

if [[ -z "$VERSION" ]]; then
  echo "DBpedia version is required (e.g. -v=2016-04)"
  exit 1
fi

if [[ -z "$LANGUAGE" ]]; then
  echo "Language is required (e.g. -l=en)"
  exit 1
fi

STOPWORDS_FILE="stopwords.$LANGUAGE.txt"

dexists("/root/data/datasets/$STOPWORDS_FILE")

cp "/root/data/datasets/$STOPWORDS_FILE" "/root/hSVM3/$STOPWORDS_FILE"
cp $PARAMETERS_TEMPLATE $PARAMETERS

sed -i -- "s/_LANG_/$LANGUAGE/g" $PARAMETERS
sed -i -- "s/_VERSION_/$VERSION/g" $PARAMETERS

while IFS='|' read -r key value
do
if [[ "$key" == "dataset_to_type" || "$key" == "DBpedia_ontology" || "$key" == "lang_short_abstracts" || "$key" == "lang_article_categories" || "$key" == "lang_instance_types" ]]; then
  dexists($value)
fi
if [[ "$key" == "sti_types_dataset" || "$key" == "sti_inference_debug" ]]; then
  if [ ! -f "$value" ]; then
    STI=0
  fi
fi 
done < "$PARAMETERS"

if [[ "$STI" == 0 ]]; then
  sed -i '/sti_types_dataset/c\sti_types_dataset|' $PARAMETERS
  sed -i '/sti_inference_debug/c\sti_types_dataset|' $PARAMETERS
fi

#cd /root/hSVM3

#mvn exec:java -Dexec.mainClass="cz.vse.swoe.linkedtv.hsvm.hSVMrun"

#mv res/hSVMSTI.nt.gz /root/data/datasets