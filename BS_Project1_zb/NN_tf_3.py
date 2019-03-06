#coding:utf-8
#0导入模块，生成模拟数据集

import tensorflow as tf
import numpy as np

BATCH_SIZE = 8
seed = 23455
########################训练数据集准备#########################
#利用随机函数和seed产生随机数
#这里只是为了生成一些数据用来输入
rng = np.random.RandomState(seed)
#随机数返回32行2列的矩阵，表示32组 体积和重量 作为输入数据集
X = rng.rand(32,2)
#从X这个矩阵中取出1行，判断如果和小于1 Y赋值1 如果和不小于1 Y赋值0
#Y作为X的数据集label（正确答案）与X数据集一一对应
Y = [[int(x0 + x1 < 1)] for (x0, x1) in X]
print "X:\n",X
print "Y:\n",Y


########################两层神经网络框架#########################
#1-定义神经网络的输入、参数、和输出，定义前向传播过程
#输入 tf.placeholder(数据类型，数据格式) 占位用
x  = tf.placeholder(tf.float32, shape = (None, 2))
y_ = tf.placeholder(tf.float32, shape = (None, 1))

#初始化权重w1,w2
#矩阵类型w1为第一层网络权重，矩阵形状2行3列，与x卷积后到达第一层（a） 3个数据
#矩阵类型w2为第一层网络权重，矩阵形状3行1列，与a卷积后到达输出层 输出1个数据y
w1 = tf.Variable(tf.random_normal([2,3], stddev = 1, seed = 1))
w2 = tf.Variable(tf.random_normal([3,1], stddev = 1, seed = 1))

#前向传播方法
a = tf.matmul(x,w1)
y = tf.matmul(a,w2)

#2-定义神经网络的损失函数及反向传播方法
#这里用y与y_的均方为损失函数
loss = tf.reduce_mean(tf.square(y-y_))
#梯度下降
train_step = tf.train.GradientDescentOptimizer(0.001).minimize(loss)
#moment下降
#train_step = tf.train.MomentumOptimizer(0.001,0.9).minimize(loss)
#adam下降
#train_step = tf.train.AdamOptimizer(0.001).minimize(loss)

#3生成会话，训练steps轮
with tf.Session() as sess:
    init_op = tf.global_variables_initializer()
    sess.run(init_op)
    #输出未训练过的参数取值
    print "w1:\n", sess.run(w1)
    print "w2:\n", sess.run(w2)
    print "\n"
    
    #训练模型
    STEPS = 3000
    for i in range(STEPS):
        #每次喂BATCH_SIZE（8）组数据
        start = (i*BATCH_SIZE) % 32
        end   = start + BATCH_SIZE
        #进行反向传播
        sess.run(train_step,feed_dict={x:X[start:end],y_:Y[start:end]})
        #每500轮打印一次损失函数的值
        if i % 500 == 0:
            total_loss = sess.run(loss, feed_dict = {x:X,y_:Y})
            print("After %d training step(s),loss on all data is %g"%(i,total_loss))
        #输出训练后的参数取值
        print "\n"
        print "w1:\n",sess.run(w1)
        print "w2:\n",sess.run(w2)
        print sess.run(y,feed_dict = {x:[[0.1,0.2],[0.5,0.6]]})