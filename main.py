#!/usr/bin/env python
# coding: utf-8

# In[2]:


#导入相关模块
from scipy.io import loadmat
from torch.utils.data import DataLoader,Dataset
from skimage import io,transform
import matplotlib.pyplot as plt
import os
import torch
from torchvision import transforms
import numpy as np
from torch.autograd import Variable # 获取变量
import matplotlib.pyplot as plt
import numpy as np

class TrainSet(Dataset): #继承Dataset
    def __init__(self): #__init__是初始化该类的一些基础参数
        m = loadmat('D:\学习\大四\毕设\code\dataset0.mat')
        self.sig = m['rsig'][0:700]
        self.label = m['y'][0:700]
        self.p = m['p'][0:700]
        #self.sig.view(700,1,1000)
        #self.label.view(700,1,2)
    
    def __len__(self):#返回整个数据集的大小
        return 700
    
    def __getitem__(self,index):#根据索引index返回dataset[index]
        sample = (self.sig[index],self.label[index],self.p[index])
        
        return sample #返回该样本

class TestSet(Dataset): #继承Dataset
    def __init__(self): #__init__是初始化该类的一些基础参数
        m = loadmat('D:\学习\大四\毕设\code\dataset0.mat')
        self.sig = m['rsig'][700:900]
        self.label = m['y'][700:900]
        self.p = m['p'][700:900] 
        
    def __len__(self):#返回整个数据集的大小
        return 200
    
    def __getitem__(self,index):#根据索引index返回dataset[index]
        sample = (self.sig[index],self.label[index],self.p[index])
        
        return sample #返回该样本
    
class VerifySet(Dataset): #继承Dataset
    def __init__(self): #__init__是初始化该类的一些基础参数
        m = loadmat('D:\学习\大四\毕设\code\dataset0.mat')
        self.sig = m['rsig'][900:1000]
        self.label = m['y'][900:1000]
        self.p = m['p'][900:1000] 
    
    def __len__(self):#返回整个数据集的大小
        return 100
    
    def __getitem__(self,index):#根据索引index返回dataset[index]
        sample = (self.sig[index],self.label[index],self.p[index])
        
        return sample #返回该样本

print('ok')


# In[3]:


#modle1
class MyNet1(torch.nn.Module):
    def __init__(self):
        super(MyNet1, self).__init__()
        self.conv1 = torch.nn.Sequential(
            torch.nn.Conv1d(in_channels = 1,
                           out_channels = 50,
                           kernel_size = 8,
                           stride = 4),
            torch.nn.ReLU()
        )
        self.conv2 = torch.nn.Sequential(
            torch.nn.Conv1d(50, 100, 6,3),
            torch.nn.ReLU()
        )
        self.conv3 = torch.nn.Sequential(
            torch.nn.Conv1d(100, 200, 4, 2),
            torch.nn.ReLU()
        )
        self.mlp1 = torch.nn.Linear(9*200, 4)
        self.mlp2 = torch.nn.Linear(4,2)
    def forward(self,x):
        x = self.conv1(x)
        x = self.conv2(x)
        x = self.conv3(x)
        x = self.mlp1(x.view(x.size(0),-1))
        x = self.mlp2(x)
        return x
#modle2
class MyNet2(torch.nn.Module):
    def __init__(self):
        super(MyNet2, self).__init__()
        self.conv1 = torch.nn.Sequential(
            torch.nn.Conv1d(in_channels = 1,
                           out_channels = 50,
                           kernel_size = 4,
                           stride = 2),
            torch.nn.ReLU()
        )
        self.conv2 = torch.nn.Sequential(
            torch.nn.Conv1d(50, 100, 3,1),
            torch.nn.ReLU(),
            torch.nn.MaxPool1d(kernel_size = 5)
        )
        self.conv3 = torch.nn.Sequential(
            torch.nn.Conv1d(100, 200, 3, 2),
            torch.nn.ReLU()
        )
        self.mlp1 = torch.nn.Sequential(
            torch.nn.Linear(12*200, 10),
            torch.nn.ReLU()
        )
        self.mlp2 = torch.nn.Sequential(
            torch.nn.Linear(10,2),
            torch.nn.ReLU()
        )

    def forward(self,x):
        x = self.conv1(x)
        x = self.conv2(x)
        x = self.conv3(x)
        x = self.mlp1(x.view(x.size(0),-1))
        x = self.mlp2(x)
        return x
#modle3
class MyNet3(torch.nn.Module):
    def __init__(self):
        super(MyNet3, self).__init__()
        self.conv1 = torch.nn.Sequential(
            torch.nn.Conv1d(in_channels = 1,
                           out_channels = 50,
                           kernel_size = 1,
                           stride = 1),
            torch.nn.ReLU()
        )
        self.conv2 = torch.nn.Sequential(
            torch.nn.Conv1d(50, 100, 1,1),
            torch.nn.ReLU(),
            torch.nn.MaxPool1d(kernel_size = 4)
        )
        self.conv3 = torch.nn.Sequential(
            torch.nn.Conv1d(100, 200, 1, 1),
            torch.nn.ReLU()
        )
        self.mlp1 = torch.nn.Sequential(
            torch.nn.Linear(64*200, 16*200),
            torch.nn.ReLU(),
            torch.nn.Linear(16*200, 200),
            torch.nn.ReLU(),
            torch.nn.Linear(200, 10),
            torch.nn.ReLU(),
        )
        self.mlp2 = torch.nn.Sequential(
            torch.nn.Linear(10,2),
            torch.nn.ReLU()
        )

    def forward(self,x):
        x = self.conv1(x)
        x = self.conv2(x)
        x = self.conv3(x)
        x = self.mlp1(x.view(x.size(0),-1))
        x = self.mlp2(x)
        return x
print('ok')


# In[209]:


c = torch.tensor([1,2,3,4,5,4,3,2,1])
s = torch.sum(c[c>3] - 3) + torch.sum(2-c[c<2])
print(s)
a = torch.randn(2)
b = torch.randn(10,2)
print(a)
z = torch.sum(b[b[:,0]>0,0])
flag = b[:,0]>0
flag1 = b[:,0]>0.1
flag2 = flag * flag1
flag = flag.float()
print(flag,flag1,flag2)
z = z.cuda()
if  z == 0:
    print('ok',torch.tensor(10))
    print(a[0]*a[1],torch.pow(a[0],2)/torch.pow(a[1],2))
    print(flag * a[0],torch.sum(b[:,0]),torch.sum(b[flag,0] * a[0]))
    


# In[4]:


#loss function
class SINRLoss(torch.nn.Module):
    def __init__(self):
        super().__init__()
        
    def forward(self,y,x,p):
        #if y[0] <=1 or y[1] <=0:
        #    return torch.tensor(10)
        N = x.size()
        x = x.view(N[0],N[2])
        sinrLoss = torch.randn(N[0], requires_grad=True)
        AveLoss = torch.sum(1.5-y[y[:,0]<1.5,0]) + torch.sum(y[y[:,0]>4,0] - 4) + torch.sum(1 - y[y[:,1]<1,1]) + torch.sum(y[y[:,1]>5,1] - 5) 
        if torch.cuda.is_available():
            sinrLoss = sinrLoss.cuda()
            AveLoss = AveLoss.cuda()
            flagGPU = True

        if AveLoss != 0:
            return AveLoss
            
        
        for j in range(N[0]):
            sig = torch.zeros(N[2], requires_grad=True)
            if flagGPU:
                sig = sig.cuda()
            xj = torch.abs(x[j,:])
            flag_at = (xj <= y[j,0] * y[j,1]) * (xj > y[j,1])
            flag_atf = flag_at.float()
            flag_t = xj <= y[j,1]
            sig[flag_t] = x[j,flag_t]
            sig += flag_atf *  y[j,1]
            #sig[flag_at] =  flag_atf *  y[j,1]
            '''for i in range(N[2]):
                xi = torch.abs(x[j][i])
                if xi <= y[j][1]:
                    sig[i] = x[j][i]
                elif xi <= y[j][0]*y[j][1]:
                    sig[i] = y[j][1]
                else:
                    sig[i] = 0'''
            n = torch.abs(sig-p[j])
            pn = torch.mean(torch.pow(n,2))
            ps = torch.mean(torch.pow(p[j],2))
            sinrLoss[j] = pn/ps
        
        AveLoss = torch.mean(sinrLoss)
        
        return AveLoss
        
            


# In[ ]:





# In[62]:


model = MyNet3()
flagGPU = False
if torch.cuda.is_available():
    model = model.cuda()
    flagGPU = True
print(model)
trainSet = TrainSet()
testSet = TestSet()
verifySet = VerifySet()
trainLoader = DataLoader(trainSet,batch_size = 10, shuffle = False)
testLoader = DataLoader(testSet,batch_size = 10, shuffle = False)
verifyLoader = DataLoader(verifySet,batch_size = 1, shuffle = False)
loss_fn = torch.nn.MSELoss()
loss_fn1 = SINRLoss()
#opt = torch.optim.Adam(model.parameters(),lr=0.00001)
opt = torch.optim.Adam(model.parameters(),lr=0.001)
#print('ok')
SINR = []
for epoch in range(20):
    for i,(x,y,p) in enumerate(trainLoader):
        if flagGPU:
            batch_x = x.cuda()
            batch_y = y.cuda()
            batch_p = p.cuda()
        else:
            batch_x = Variable(x)
            batch_y = Variable(y)
            batch_p = Variable(p)
        #print(batch_x,batch_y)
        #print(batch_x.size())
        batch_x = batch_x.view(10,1,256)
        batch_y = batch_y.view(10,1,2)
        batch_x = batch_x.float()
        batch_y = batch_y.float()
        batch_p = batch_p.float()
        out = model(batch_x)
        #print(batch_x.size())
        #loss = loss_fn(out, batch_y)
        loss = loss_fn1(out,batch_x,batch_p)
        opt.zero_grad()
        loss.backward()
        opt.step()
        #print(loss)
        if i%35 == 0:
            print('Training loss: ',loss.data.item())
            #torch.save(model,r'D:\学习\大四\毕设\code\myNet')
    t_loss = []
    sinr_pred = []
    sinr_real = []
    for a,b,c in testLoader:
        if flagGPU:
            test_x = a.cuda()
            test_y = b.cuda()
            test_p = c.cuda()
        else:
            test_x = Variable(a)
            test_y = Variable(b)
            test_p = Variable(p)

        test_x = test_x.view(10,1,256)
        test_x = test_x.float()
        test_y = test_y.view(10,1,2)
        test_y = test_y.float()
        test_p = test_p.float()
        out = model(test_x)
        t_loss_item = loss_fn(out, test_y)
        t_loss.append(t_loss_item.data.item())
        sinr_pred_item = loss_fn1(out, test_x, batch_p)
        sinr_pred.append(-10*np.log(sinr_pred_item.data.item()))
        sinr_real_item = loss_fn1(test_y.view(10,2), test_x, batch_p)
        sinr_real.append(-10*np.log(sinr_real_item.data.item()))
    print('epoch= ',epoch,', Testing loss: ',np.mean(t_loss))
    print('predict SINR = ',np.mean(sinr_pred),' best SINR = ',np.mean(sinr_real))
    SINR.append(np.mean(sinr_pred))

v_a =[]
v_t = []
sinr_pred = []
sinr_real = []
t_loss = []
for a,b,c in verifyLoader:
    if flagGPU:
        test_x = a.cuda()
        test_y = b.cuda()
        test_p = c.cuda()
    else:
        test_x = Variable(a)
        test_y = Variable(b)
        test_p = Variable(p)

    test_x = test_x.view(1,1,256)
    test_x = test_x.float()
    test_y = test_y.view(1,1,2)
    test_y = test_y.float()
    test_p = test_p.float()
    out = model(test_x)
    v_a.append(out[0,0].data.item())
    v_t.append(out[0,1].data.item())
    t_loss_item = loss_fn(out, test_y)
    t_loss.append(t_loss_item.data.item())
    sinr_pred_item = loss_fn1(out, test_x, batch_p)
    sinr_pred.append(-10*np.log(sinr_pred_item.data.item()))
    sinr_real_item = loss_fn1(test_y.view(1,2), test_x, batch_p)
    sinr_real.append(-10*np.log(sinr_real_item.data.item()))
print('Verifing loss: ',np.mean(t_loss))
print('predict SINR = ',np.mean(sinr_pred),' BF SINR = ',np.mean(sinr_real))
SINR.append(np.mean(sinr_pred))

#print(v_t)
print(np.min(sinr_pred),np.mean(sinr_pred),np.max(sinr_pred))
print(np.min(v_a),np.mean(v_a),np.max(v_a))
print(np.min(v_t),np.mean(v_t),np.max(v_t))
    


# In[55]:


v_a =[]
v_t = []
sinr_pred = []
sinr_real = []
t_loss = []
for a,b,c in verifyLoader:
    if flagGPU:
        verify_x = a.cuda()
        verify_y = b.cuda()
        verify_p = c.cuda()
    else:
        verify_x = Variable(a)
        verify_y = Variable(b)
        verify_p = Variable(p)

    verify_x = verify_x.view(1,1,256)
    verify_x = verify_x.float()
    verify_y = verify_y.view(1,1,2)
    verify_y = verify_y.float()
    verify_p = verify_p.float()
    out = model(verify_x)
    v_a.append(out[0,0].data.item())
    v_t.append(out[0,1].data.item())
    t_loss_item = loss_fn(out, verify_y)
    t_loss.append(t_loss_item.data.item())
    sinr_pred_item = loss_fn1(out, verify_x, verify_p)
    sinr_pred.append(-10*np.log(sinr_pred_item.data.item()))
    sinr_real_item = loss_fn1(verify_y.view(1,2), verify_x, verify_p)
    sinr_real.append(-10*np.log(sinr_real_item.data.item()))
print('Verifing loss: ',np.mean(t_loss))
print('predict SINR = ',np.mean(sinr_pred),' best SINR = ',np.mean(sinr_real))
SINR.append(np.mean(sinr_pred))

#print(v_t)
print(np.min(sinr_pred),np.mean(sinr_pred),np.max(sinr_pred))
print(np.min(v_a),np.mean(v_a),np.max(v_a))
print(np.min(v_t),np.mean(v_t),np.max(v_t))


# In[48]:


print(test_y,test_y.view(10,2))


# In[ ]:





# In[56]:



v_a =[]
v_t = []
sinr_pred = []
sinr_real = []
t_loss = []
for a,b,c in verifyLoader:
    if flagGPU:
        test_x = a.cuda()
        test_y = b.cuda()
        test_p = c.cuda()
    else:
        test_x = Variable(a)
        test_y = Variable(b)
        test_p = Variable(p)

    test_x = test_x.view(1,1,256)
    test_x = test_x.float()
    test_y = test_y.view(1,1,2)
    test_y = test_y.float()
    test_p = test_p.float()
    out = model(test_x)
    v_a.append(out[0,0].data.item())
    v_t.append(out[0,1].data.item())
    t_loss_item = loss_fn(out, test_y)
    t_loss.append(t_loss_item.data.item())
    sinr_pred_item = loss_fn1(out, test_x, batch_p)
    sinr_pred.append(-10*np.log(sinr_pred_item.data.item()))
    sinr_real_item = loss_fn1(test_y.view(1,2), test_x, batch_p)
    sinr_real.append(-10*np.log(sinr_real_item.data.item()))
print('Verifing loss: ',np.mean(t_loss))
print('predict SINR = ',np.mean(sinr_pred),' BF SINR = ',np.mean(sinr_real))
SINR.append(np.mean(sinr_pred))

#print(v_t)
print(np.min(sinr_pred),np.mean(sinr_pred),np.max(sinr_pred))
print(np.min(v_a),np.mean(v_a),np.max(v_a))
print(np.min(v_t),np.mean(v_t),np.max(v_t))
    
    


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[19]:


#导入相关模块
from scipy.io import loadmat
from torch.utils.data import DataLoader,Dataset
from skimage import io,transform
import matplotlib.pyplot as plt
import os
import torch
from torchvision import transforms
import numpy as np
from torch.autograd import Variable # 获取变量
import matplotlib.pyplot as plt
import numpy as np

class TrainSet(Dataset): #继承Dataset
    def __init__(self): #__init__是初始化该类的一些基础参数
        m = loadmat('D:\学习\大四\毕设\code\dataset0.mat')
        self.sig = m['rsig'][0:700]
        self.label = m['y'][0:700]
        #self.sig.view(700,1,1000)
        #self.label.view(700,1,2)
    
    def __len__(self):#返回整个数据集的大小
        return 700
    
    def __getitem__(self,index):#根据索引index返回dataset[index]
        sample = (self.sig[index],self.label[index])
        
        return sample #返回该样本

class TestSet(Dataset): #继承Dataset
    def __init__(self): #__init__是初始化该类的一些基础参数
        m = loadmat('D:\学习\大四\毕设\code\dataset0.mat')
        self.sig = m['rsig'][700:900]
        self.label = m['y'][700:900]
    
    def __len__(self):#返回整个数据集的大小
        return 200
    
    def __getitem__(self,index):#根据索引index返回dataset[index]
        sample = (self.sig[index],self.label[index])
        
        return sample #返回该样本
    
class VerifySet(Dataset): #继承Dataset
    def __init__(self): #__init__是初始化该类的一些基础参数
        m = loadmat('D:\学习\大四\毕设\code\dataset0.mat')
        self.sig = m['rsig'][900:1000]
        self.label = m['y'][900:1000]
    
    def __len__(self):#返回整个数据集的大小
        return 100
    
    def __getitem__(self,index):#根据索引index返回dataset[index]
        sample = (self.sig[index],self.label[index])
        
        return sample #返回该样本

    
class MyNet(torch.nn.Module):
    def __init__(self):
        super(MyNet, self).__init__()
        self.conv1 = torch.nn.Sequential(
            torch.nn.Conv1d(in_channels = 1,
                           out_channels = 50,
                           kernel_size = 4,
                           stride = 2),
            torch.nn.ReLU()
        )
        self.conv2 = torch.nn.Sequential(
            torch.nn.Conv1d(50, 100, 3,1),
            torch.nn.ReLU(),
            torch.nn.MaxPool1d(kernel_size = 5)
        )
        self.conv3 = torch.nn.Sequential(
            torch.nn.Conv1d(100, 200, 3, 2),
            torch.nn.ReLU()
        )
        self.mlp1 = torch.nn.Sequential(
            torch.nn.Linear(12*200, 10),
            torch.nn.ReLU()
        )
        self.mlp2 = torch.nn.Sequential(
            torch.nn.Linear(10,2),
            torch.nn.ReLU()
        )

    def forward(self,x):
        #print(x.size())
        x = self.conv1(x)
        #print(x.size())
        x = self.conv2(x)
        #print(x.size())
        x = self.conv3(x)
        #print(x.size())
        x = self.mlp1(x.view(x.size(0),-1))
        #print(x.size())
        x = self.mlp2(x)
        #print(x.size())
        return x
    
model = MyNet()
flagGPU = False
if torch.cuda.is_available():
    model = model.cuda()
    flagGPU = True
print(model)
trainSet = TrainSet()
testSet = TestSet()
verifySet = VerifySet()
trainLoader = DataLoader(trainSet,batch_size = 10, shuffle = True)
testLoader = DataLoader(testSet,batch_size = 10, shuffle = True)
verifyLoader = DataLoader(verifySet,batch_size = 10, shuffle = True)
loss_fn = torch.nn.MSELoss()
opt = torch.optim.Adam(model.parameters(),lr=0.00001)
#print('ok')
for epoch in range(200):
    for i,(x,y) in enumerate(trainLoader):
        if flagGPU:
            batch_x = x.cuda()
            batch_y = y.cuda()
        else:
            batch_x = Variable(x)
            batch_y = Variable(y)
        #print(batch_x,batch_y)
        #print(batch_x.size())
        batch_x = batch_x.view(10,1,256)
        batch_y = batch_y.view(10,1,2)
        batch_x = batch_x.float()
        batch_y = batch_y.float()
        out = model(batch_x)
        #print(batch_x.size())
        loss = loss_fn(out, batch_y)
        opt.zero_grad()
        loss.backward()
        opt.step()
        #print(loss)
        if i%50 == 0:
            print('Training loss: ',loss.data.item())
            torch.save(model,r'D:\学习\大四\毕设\code\myNet')
    t_loss = []
    for a,b in testLoader:
        if flagGPU:
            test_x = a.cuda()
            test_y = b.cuda()
        else:
            test_x = Variable(a)
            test_y = Variable(b)

        test_x = test_x.view(10,1,256)
        test_x = test_x.float()
        test_y = test_y.view(10,1,2)
        test_y = test_y.float()
        out = model(test_x)
        t_loss_item = loss_fn(out, test_y)
        t_loss.append(t_loss_item.data.item())
    print('epoch= ',epoch,', Testing loss: ',np.mean(t_loss))
        
print('real:',test_y)
print('predict:',out)

    
    


# In[62]:


len('model4')


# In[ ]:





# In[ ]:




