#!/usr/bin/env python3

import os
import time
import threading
import numpy as np

from rknnlite.api import RKNNLite


MODEL_PATH = "/home/linaro/yolov8/yolov8.rknn"


THREAD_NUM = 6


CORE_LIST = [
    RKNNLite.NPU_CORE_0,
    RKNNLite.NPU_CORE_0,

    RKNNLite.NPU_CORE_1,
    RKNNLite.NPU_CORE_1,

    RKNNLite.NPU_CORE_2,
    RKNNLite.NPU_CORE_2,
]


# YOLOv8 input
IMG_SIZE = 640


def create_input():

    img = np.random.randint(
        0,
        255,
        (
            1,
            3,
            IMG_SIZE,
            IMG_SIZE
        ),
        dtype=np.uint8
    )

    return img



def worker(index):

    core = CORE_LIST[index]


    os.environ["RKNN_LOG_LEVEL"] = "0"


    rknn = RKNNLite()


    ret = rknn.load_rknn(
        MODEL_PATH
    )


    if ret != 0:
        print(
            "Thread",
            index,
            "load failed"
        )
        return



    ret = rknn.init_runtime(
        core_mask=core
    )


    if ret != 0:
        print(
            "Thread",
            index,
            "runtime failed"
        )
        return



    print(
        "Thread",
        index,
        "running on",
        core
    )


    input_data = create_input()


    count = 0

    start = time.time()



    while True:

        try:

            outputs = rknn.inference(
                inputs=[
                    input_data
                ]
            )


            count += 1


            now = time.time()


            if now-start >= 10:

                fps = count/(now-start)


                print(
                    "Thread %d FPS %.2f"
                    %
                    (
                        index,
                        fps
                    )
                )


                count=0
                start=now


        except Exception as e:

            print(
                "Thread",
                index,
                e
            )

            break



    rknn.release()



def main():


    print("============================")
    print("RK3588 NPU Stress Test")
    print("Threads:", THREAD_NUM)
    print("============================")


    threads=[]


    for i in range(THREAD_NUM):

        t=threading.Thread(
            target=worker,
            args=(i,),
            daemon=True
        )

        t.start()

        threads.append(t)



    while True:

        time.sleep(60)



if __name__=="__main__":

    main()
