'''
该代码用于学习生成TfRecord格式文件
我的输入是浮点数，所以需要研究如何保存浮点数
'''
import scipy.io as sio #该库用于从.mat文件中读取数据
import matplotlib.pyplot as plt 
import numpy as np 
import tensorflow as tf
import os

#将数据写入文件
def encode_to_tfrecords(tfrecords_filename): 
    ''' write into tfrecord file '''
    if os.path.exists(tfrecords_filename):
        os.remove(tfrecords_filename)

    writer = tf.python_io.TFRecordWriter(tfrecords_filename) # 创建.tfrecord文件，准备写入
    
    fileName="/home/jd/VeryImportantWork/env_data1.mat"
    data=sio.loadmat(fileName)
    concs=data['conc']#注意，读取出来的数据是numpy矩阵的形式
    
    for conc in concs:
        conc1=[1.011,2.011,3.011]#测试数据，一个list
        #conc_str=conc.tostring()#将矩阵转换为list
        example = tf.train.Example(
            features=tf.train.Features(
                feature={
                'label': tf.train.Feature(int64_list = tf.train.Int64List(value=[1])),     
                'conc':tf.train.Feature(float_list = tf.train.FloatList(value=conc1))
                }))
        writer.write(example.SerializeToString()) 

    writer.close()

#从文件中读数据
def decode_from_tfrecords(filename_queue, is_batch):

    reader = tf.TFRecordReader()
    _, serialized_example = reader.read(filename_queue)   #返回文件名和文件
    features = tf.parse_single_example(serialized_example,
                                       features={
                                           'label': tf.FixedLenFeature([1], tf.int64),
                                           'conc' : tf.FixedLenFeature([3], tf.float32),
                                       })  #取出包含image和label的feature对象，注意tf.FixedLenFeature(）中的方括号，如果你已经知道维度，就把它写清楚
    conc = features['conc']
    label = features['label']

    if is_batch:
        conc, label = tf.train.shuffle_batch([conc, label],batch_size=6, num_threads=2, capacity=100,min_after_dequeue=50)
    return conc, label

if __name__ == '__main__':
    # make train.tfrecord
    train_filename = "/home/jd/VeryImportantWork/env_data3.tfrecords"
    encode_to_tfrecords(train_filename)

    # run_test = True
    filename_queue = tf.train.string_input_producer([train_filename],num_epochs=None) #读入流中
    train_conc, train_label = decode_from_tfrecords(filename_queue, is_batch=True)
    with tf.Session() as sess: #开始一个会话，尽量使用这种写法，避免程序有问题非正常关闭导致资源没有释放
        init_op = tf.global_variables_initializer()
        sess.run(init_op)
        threads= tf.train.start_queue_runners(sess=sess)
        try:
            # while not coord.should_stop():
            for i in range(30):
                example, l = sess.run([train_conc,train_label])#在会话中取出image和label
                print('train:')
                print(example, l) 
        except tf.errors.OutOfRangeError:
            print('Done reading')
        finally:
            print("done")