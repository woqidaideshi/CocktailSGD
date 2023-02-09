netif=ens5
export GLOO_SOCKET_IFNAME=${netif}
export NCCL_SOCKET_IFNAME=${netif}
export WANDB_NAME=opt-125m-cot

export QUANT_BITS=4
export TOPK_RATIO=0.2
export RANDOMP_RATIO=0.1

export SHOW_DATA=0
cd ../
ARGS="--model-name ./empty_model_configs/opt-125m \
--tokenizer-name ./empty_model_configs/opt-125m \
--load-pretrained-model false \
--project-name cocktail-allreduce-node1-testbase \
--model-type opt \
--optimizer adam \
--seed 42 \
--task-name cot \
--checkpoint-path ./model_ckpts/$WANDB_NAME-testbase \
--num-layers 12 --embedding-dim 768 \
--total-steps 200 --warmup-steps 10 --train-warmup-steps 0 \
--checkpoint-steps 100 \
--lr 1e-4 --seq-length 2048 --batch-size 16 --micro-batch-size 1 --gradient-accumulate-step 1 \
--dist-url tcp://127.0.0.1:7033 \
--world-size 1 --pipeline-group-size 1 --data-group-size 1 \
--job-id 0 --net-interface ${netif} \
--fp16 \
--dp-backend gloo \
--dp-mode allreduce \
--pp-mode gpipe --profiling no-profiling"

(trap 'kill 0' SIGINT; \
python3 dist_lm_train.py $(echo ${ARGS}) --cuda-id 0 --rank 0 \
    & \
# python dist_lm_train.py $(echo ${ARGS}) --cuda-id 4 --rank 0 \
#     & \
# python dist_lm_train.py $(echo ${ARGS}) --cuda-id 5 --rank 1 \
#     & \
# python dist_lm_train.py $(echo ${ARGS}) --cuda-id 6 --rank 2 \
#     & \
# python dist_lm_train.py $(echo ${ARGS}) --cuda-id 7 --rank 3 \
#     & \
wait)

