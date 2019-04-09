ffmpeg="/bin/anaconda3/bin/ffmpeg"
ffprobe="/bin/anaconda3/bin/ffprobe"
eval_loc="./database/evaluation_subset.tsv"
train_loc="./database/balanced_training_subset.tsv"
#unbal_loc="./database/evaluation_subset.tsv"
data_dir="./database"

#eval_loc="./database/test_eval.csv"
#train_loc="./database/test_balanced.csv"
unbal_loc="./database/test_unbalanced.csv"

python ~/audiosetdl/download_audio_only.py $data_dir -e $eval_loc -b $train_loc -u $unbal_loc
#python ./database/download_audioset.py $data_dir -e $eval_loc -b $train_loc -u $unbal_loc
