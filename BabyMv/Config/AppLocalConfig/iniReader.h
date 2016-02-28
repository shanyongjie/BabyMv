//
//  iniReader.h
//  KWPlayer
//
//  Created by 刘 强 on 12-1-12.
//  Copyright (c) 2012年 Kuwo Beijing Co., Ltd. All rights reserved.
//  从音乐盒搬过来

#ifndef KWPlayer_iniReader_h
#define KWPlayer_iniReader_h
//
//  main.m
//  iniReader
//
//  Created by 刘 强 on 12-1-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <string>
#import <fstream>
#import <vector>
#include <iostream>
#import <map>
using namespace std;



struct Node
{
    string sectionName;
    map<string,string>  dict;
    Node * next;
};


class LinkList
{
private:
    Node* startNode;
    size_t len;
public:
    LinkList();
    ~LinkList();
    Node* getHead();
    string getValueByKeyInsection(const string &secName, const string &key);
    void  addSectionAndDict(const char*secName, map<string,string>& dict);
    void  deleteAll();
    void addSectionKeyValue(const string& secName, const string&key, const string&value);
};





class iniReader
{
public:
    iniReader(string _iniName);
    iniReader();
    ~iniReader();
    
private:    
    string& trim(std::string &s); 
    bool getSectionFromLineStr(string& sline);
    void addSectionValueKey(const char*secName ,const char*value, const char* key);
    bool isSec(string  lineStr);
    void getKeyValueFromLineStr(string &key, string &value, string &sline);
    string& keyStrToLowerCase(string &keyStr);
public:
    bool loadIniInfo(const char* fileName);  
    bool hasSection(const char* section);
    bool findIntValueInSectionByKey(int &value, const string &key, const string &section);
    bool findStringValueInSectionByKey(string  &value, const char*key, const char*section);
    bool findBoolValueInSectionByKey(bool &value, const char*key, const char*section);
    bool writeStrValueInSectionByKey(const string &value, const string&key, const string&section);
    bool writeIni(const char*fileName);
    friend inline ofstream &operator<<(ofstream &os, iniReader& ir);
    
private:
    string iniName;
    LinkList *pLinkList;
};






#endif
