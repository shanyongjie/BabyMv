//
//  main.m
//  iniReader
//
//  Created by 刘 强 on 12-1-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//  从音乐盒搬过来

#import <string>
#import "iniReader.h"
#import <fstream>
#import <vector>
#include <iostream>
#import <map>
using namespace std;



Node* LinkList::getHead()
{
    return startNode;
}
void LinkList::addSectionKeyValue(const string& secName, const string&key, const string&value)
{
    Node *tnode=startNode;
    Node *lastNode = NULL;
    while(tnode)
    {
        if(tnode->sectionName == secName)
        {
            tnode->dict[key]=value;
            //tnode->dict.insert(pair<string,string>(key,value));//这句是从k歌直接搬过来的，根本不能替换，真不知道他们的程序是怎么跑了一年的。。。
            return ;
        }
        lastNode = tnode;
        tnode = tnode->next;        
    }
    if (!lastNode) {
        return;
    }
    
    map<string,string> mp ;
    mp.insert(pair<string,string>(key,value));
    Node *addNode = new Node;
    addNode->sectionName = secName;
    addNode->dict = mp;
    addNode->next = 0;
    lastNode->next = addNode;
}

LinkList::LinkList()
{
    startNode = new Node;
    startNode->next = 0;
    len = 0;
}
LinkList::~LinkList()
{
    deleteAll();
}

string  LinkList::getValueByKeyInsection(const string &secName, const string &key)
{
    map<string, string>::iterator iter;
    Node *tnode = startNode;
    while (tnode) 
    {
        if (tnode->sectionName == secName) 
        {
            iter = tnode->dict.find(key);
            if(iter != tnode->dict.end())
                return iter->second;
            else 
                return "";
        }
        tnode = tnode->next;
    }
    return ""; 
}


void LinkList::addSectionAndDict(const char*secName, map<string,string>& dict)
{
    Node* tnode = startNode;
    Node* lastNode = NULL;
    while (tnode) {
        if (tnode->sectionName == secName) {
            for(map<string,string >::iterator iter=dict.begin();
                iter != dict.end(); iter++)
            {
                tnode->dict.insert(pair<string,string>(iter->first,iter->second) );
                return ;
            }
        }
        lastNode = tnode;
        tnode = tnode->next;
    }
    if (!lastNode) {
        return;
    }
    
    Node* addNode = new Node();
    addNode->sectionName = secName;
    addNode->dict = dict;
    addNode->next = 0;
    lastNode->next = addNode;
}
void LinkList::deleteAll()
{
    Node* tnode = startNode;
    while (tnode) {
        Node *nextNode = tnode->next;
        delete tnode;        
        tnode = nextNode;
    }
}

inline ofstream & operator<<(ofstream &os, LinkList& lklist)
{
    Node *tnode = lklist.getHead();
    while(tnode)
    {
        if(tnode->sectionName != "")
        {
            os<<"["<<tnode->sectionName<<"]"<<'\n';
            for(map<string, string>::iterator iter=tnode->dict.begin();
                iter!=tnode->dict.end()&&!(tnode->dict.empty()); iter++)
            {
                string strtemp = iter->second;
                os << iter->first << "=" << iter->second << '\n';
            }
        }
        tnode = tnode->next;
    }    
    return os;
}
bool iniReader::writeStrValueInSectionByKey(const string &value, const string&key, const string&section)
{    
    pLinkList->addSectionKeyValue(section,key,value);
    return true;
}

bool iniReader::findIntValueInSectionByKey(int &value, const string &key, const string &section)
{
    string svalue =  pLinkList->getValueByKeyInsection(section, key);
    if(svalue == "")
        return false;
    if(svalue[0]=='0' && svalue[1]=='x')
    {        
        svalue = svalue.substr(2);
        sscanf(svalue.c_str(),"%x",&value);
    }
    else
    {
        sscanf(svalue.c_str(),"%d", &value);
    }
    return true;
}
bool iniReader::findStringValueInSectionByKey(string  &value, const char*key, const char*section)
{
    string strValue = pLinkList->getValueByKeyInsection(section, key);
    if(strValue=="")
        return false;
    return value=strValue,true;
}
bool iniReader::findBoolValueInSectionByKey(bool &value,  const char*key, const char*section)
{
    string bValue = pLinkList->getValueByKeyInsection(section, key);
    if(bValue == "")
    {
        return false;        
    }
    if(bValue=="1" || bValue=="true" || bValue =="YES" || bValue == "TRUE" || bValue=="yes")
    {
        value = true;
        return true;
    }
    value = false;
    return true;    
}


iniReader::iniReader(string _iniName)
{
    iniName = _iniName;
}
iniReader::iniReader()
{
    pLinkList  = new LinkList;
}

bool iniReader::writeIni(const char*fileName)
{
    
    ofstream os(fileName,ios::out);
    if(!os)
    {
        return false;
    }
    os << *pLinkList;
    return true;
}
bool iniReader::loadIniInfo(const char* fileName)
{
    ifstream  iReadSection(fileName,ios::in);
    if(!iReadSection)
    {
        return false;
    }
    
    string sline;
    map<string, string> map;
    string secName="";
    
    while(getline(iReadSection,sline,'\n'))
    {
        if(isSec(sline.c_str()) )
        {            
            if(secName != "")
            {
                pLinkList->addSectionAndDict(secName.c_str(), map);
            }
            
            map.clear();
            getSectionFromLineStr(sline);          
            secName = sline;
        }       
        else
        {
            string key;
            string value;
            getKeyValueFromLineStr(key, value, sline);
            map.insert(pair<string,string>(key,value));
        }
    }
    pLinkList->addSectionAndDict(secName.c_str(), map);
    iReadSection.close();
    return true;
}
string& iniReader::keyStrToLowerCase(string &keyStr)
{
    const char *p = keyStr.c_str();
    while (*p++) {
        if(isupper(*p))
        {
            tolower(*p);
        }
    }
    return keyStr;
}

void iniReader::getKeyValueFromLineStr(string &key, string &value, string &sline)
{
    int equal_pos = sline.find("=");
    if(equal_pos == string::npos)
    {
        return;
    }
    string keyStr = sline.substr(0,equal_pos);
    key = keyStrToLowerCase(trim(keyStr));
    
    int end_pos = sline.find('\n');
    string valueStr = sline.substr(equal_pos+1,end_pos-end_pos-1);
    value = trim(valueStr);
}

bool iniReader::isSec(string  lineStr)
{
    int start_pos = lineStr.find("[");
    if(start_pos == string::npos)
    {
        return false;
    }
    return true;
}

bool iniReader::getSectionFromLineStr(string &sline)
{
    int start_pos = sline.find("[");
    if(start_pos == string::npos)
    {
        return false;
    }
    
    int end_pos = sline.find("]");  
    if(end_pos == string::npos)
    {
        return false;
    }
    
    sline = sline.substr(start_pos+1,end_pos-start_pos-1);
    return true;
}
string& iniReader::trim(std::string &s) 
{
    if (s.empty())
    {
        return s;
    }
    s.erase(0,s.find_first_not_of(" "));
    s.erase(s.find_last_not_of(" ") + 1);
    return s;
}
iniReader::~iniReader()
{
    
}









