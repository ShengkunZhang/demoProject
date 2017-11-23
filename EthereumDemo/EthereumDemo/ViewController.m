//
//  ViewController.m
//  EthereumDemo
//
//  Created by zsk on 2017/11/20.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "ViewController.h"
#import <Geth/Geth.h>
#import "TCFileManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"以太坊iOS客户端测试";
    [self initEthereumClient];
}

- (void)initEthereumClient {
    // 创建文件夹
    NSString *documentPath = [TCFileManager documentsDir];
    NSString *keystorePath = [documentPath stringByAppendingPathComponent:@"keystore"];
    NSString *dataPath = [documentPath stringByAppendingPathComponent:@"data"];
    if (![TCFileManager isExistsAtPath:keystorePath]) {
        [TCFileManager createDirectoryAtPath:keystorePath];
    }
    if (![TCFileManager isExistsAtPath:dataPath]) {
        [TCFileManager createDirectoryAtPath:dataPath];
    }
    // NSLog(@"documentPath>>%@", keystorePath);
    // NSLog(@"documentPath>>%@", dataPath);
    
    /*
     GethMainnetGenesis() *正式的以太坊*
     GethRinkebyGenesis() *Rinkeby测试网络*
     GethTestnetGenesis() *Ropsten测试网络*
     */
    // NSLog(@"GethMainnetGenesis>>%@", GethMainnetGenesis());
    // NSLog(@"GethRinkebyGenesis>>%@", GethRinkebyGenesis());
    // NSLog(@"GethTestnetGenesis>>%@", GethTestnetGenesis());
    
    NSError *error;
    // 先创建一个节点配置
    GethNodeConfig *nodeConfig = GethNewNodeConfig();
    // 网络模式设置
    nodeConfig.ethereumGenesis = GethRinkebyGenesis();
    // 开启以太坊协议
    nodeConfig.ethereumEnabled = YES;
    // 开启whisper协议
    nodeConfig.whisperEnabled = YES;
    nodeConfig.ethereumDatabaseCache = 100;
    // 创建一个新的节点
    GethNode *node = GethNewNode(dataPath, nodeConfig, &error);
    // 开启P2P网络
    [node start:&error];
    
    // NSLog(@"getName>>%@", node.getNodeInfo.getName);
    // NSLog(@"getID>>%@", node.getNodeInfo.getID);
    // NSLog(@"getIP>>%@", node.getNodeInfo.getIP);
    // NSLog(@"getEnode>>%@", node.getNodeInfo.getEnode);
    // NSLog(@"getListenerAddress>>%@", node.getNodeInfo.getListenerAddress);
    
    // 获得以太坊客户端
    GethEthereumClient *client = [node getEthereumClient:&error];
    GethSyncProgress *syncProgress = [client syncProgress:GethNewContext() error:&error];
    NSLog(@"第-2个error>>%@", error);
    NSLog(@"getCurrentBlock%lld", syncProgress.getCurrentBlock);
    // 获得某个位置的块
    GethBlock *block = [client getBlockByNumber:GethNewContext() number:0 error:nil];
    NSLog(@"getHash>>%@", block.getHash.getHex);
    NSLog(@"getParentHash>>%@", block.getParentHash.getHex);
    
    // keystore
    GethKeyStore *keyStore = GethNewKeyStore(keystorePath, GethLightScryptN, GethLightScryptP);
    // 先保证有一个账号
    if (keyStore.getAccounts.size == 0) {
        // 创建新的账户
        GethAccount *accout = [keyStore newAccount:@"abc123456789" error:&error];
        NSLog(@"第一个error>>%@", error);
        NSLog(@"第一个getAddress>>%@", accout.getAddress.getHex);
    }

    // 从本地文件中恢复一个账号
    NSString *fileName = [TCFileManager listFilesInDirectoryAtPath:keystorePath deep:NO][0];
    NSString *getKeyStorePath = [keystorePath stringByAppendingPathComponent:fileName];
    /* 
     从本地的keystore文件夹下找到文件，从这个文件中找到一个账号
     passphrase:这个文件生成时，这个账号的密码
     newPassphrase:恢复后这个账号可以设置一个新的密码 
     */
    GethAccount *otherAccount = [keyStore importKey:[NSData dataWithContentsOfFile:getKeyStorePath] passphrase:@"abc123456789" newPassphrase:@"abc123456789" error:&error];
    // 打印错误信息
    // NSLog(@"第二个error>>%@", error);
    // NSLog(@"getURL>>%@", otherAccount.getURL);
    NSLog(@"getAddress>>%@", otherAccount.getAddress.getHex);
    GethBigInt *bigInt = [client getBalanceAt:GethNewContext() account:otherAccount.getAddress number:-1 error:&error];
    NSLog(@"余额为：%@", bigInt.string);
    
    
    /* 
     otherAccount.getURL
     返回的是:
     keystore:///var/mobile/Containers/Data/Application/C3ED4B34-A5F5-4484-98D5-48127417857F/Documents/keystore/UTC--2017-11-22T04-33-46.877793000Z--0ad2d9c71b7928f1625acab8c94c02ce76e131e3
     即'keystore://' + '这个文件的路径'
     这个文件的路径:/var/mobile/Containers/Data/Application/C3ED4B34-A5F5-4484-98D5-48127417857F/Documents/keystore/UTC--2017-11-22T04-33-46.877793000Z--0ad2d9c71b7928f1625acab8c94c02ce76e131e3
     */
}


@end
