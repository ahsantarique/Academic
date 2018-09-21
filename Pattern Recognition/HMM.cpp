// use c++ 11 to compile, otherwise it will give compilation error

#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <utility>
#include <random>
#include <chrono>
#include <bitset>
#include <stack>

using namespace std;

ifstream in;
ofstream out;

/** global **/
vector <double> h;
vector <double> pstate, meanobservation;
vector < pair<double,double> > ptransition;
vector < vector <double > > pLogwx, translation;
vector <double> xtest;

int n;
double sigma;
/**/

void readConfig()
{
    in.open("config.txt");
    in >> n >> sigma;

    double t, htotal = 0;
    for(int i= 0; i < n; i++){
        in >> t;
        h.push_back(t);
        htotal += t;
    }
    //normalize h
    for(int i= 0; i < n; i++){
        h[i] /= htotal;

    }
    in.close();
}

void init()
{
    int k = pow(2,n);
    pstate.assign(k, 0);
    meanobservation.assign(k, 0);
    ptransition.assign(k, pair <double,double>() );
}

double noiseGen()
{
    unsigned seed = std::chrono::system_clock::now().time_since_epoch().count();
    std::default_random_engine generator (seed);
    normal_distribution<double> distribution (0.0,sigma);

    return distribution(generator);
}

double transmit(string ii)
{
    double x = 0;
    for(int j=n-1; j>=0; j--){
        if(ii[j]=='1'){
            x += h[n-1-j];
        }
    }
    // add noise
    x += noiseGen();
    return x;
}

void train()
{
    in.open("train.txt");

    long totalstate = 0, w;
    char c;
    string ii = "";

    for(int i=0; i <n; i++){
        in >> c;
        ii += c;
    }
    //calculate xk for first n bits
    double x = transmit(ii);
    w = strtol(ii.c_str(), new char *, 2);
    meanobservation[w]+= x;
    pstate[w]++;
    totalstate++;

    while(in >> c){
        //add to ptransition first
        if(c== '0') ptransition[w].first++;
        else ptransition[w].second++;

        // add new w to pstate
        ii.erase(0,1);
        ii += c;
        w = strtol(ii.c_str(), new char *, 2);
        pstate[w]++;
        totalstate++;

        x = transmit(ii);
        meanobservation[w]+= x;
    }
    /** close train.txt **/
    in.close();

    //normalize all matrices (calculate mean and probability)
    for(int i= 0; i < pstate.size(); i++){
        //calculate transition probability
        meanobservation[i] /= pstate[i];
        ptransition[i].first /= pstate[i];
        ptransition[i].second /= pstate[i];
        //calculate p(w) itself
        pstate[i] /= totalstate;
        cout<< pstate[i] <<" " << ptransition[i].first << " " << ptransition[i].second << " " << meanobservation[i] << endl;
    }
}

void generateTransmission()
{
    in.open("test.txt");
    out.open("testTransmission.txt");

    char c;
    string ii = "";
    for(int i=0; i <n; i++){
        in >> c;
        ii += c;
    }
    //calculate xk for first n bits
    double x = transmit(ii);
    out << x << " ";
    xtest.push_back(x);

    while(in >> c){
        // add new w to pstate
        ii.erase(0,1);
        ii += c;
        //calculate xk
        x = transmit(ii);
        out << x << " ";
        xtest.push_back(x);
    }
    cout << "\nTransmition complete!" << endl;
    out.close();
    in.close();
}

double pLogGaussian(int w, double x){
    return  - ( pow((x-meanobservation[w]),2)/(2*pow(sigma,2)) );
}

void test()
{
    pLogwx.assign( pow(2,n), vector<double>(xtest.size(), -99999999));
    translation.assign( pow(2,n), vector<double>(xtest.size(), -1));

    /*********** use viterbi **********/
    double x = xtest[0];
    //first observation x = x0
    for(int w = 0; w < pstate.size(); w++){
        pLogwx[w][0]= log(pstate[w]) + pLogGaussian(w,x);
    }

    for(int i=1; i < xtest.size(); i++){
        x = xtest[i];
        for(int w = 0; w < pstate.size(); w++){
            double wnext0 = (w << 1) & ((1<<n)-1);
            double wnext1 = wnext0 + 1;
            double candidate = pLogwx[w][i-1] + pLogGaussian(wnext0,x) + log(ptransition[w].first);
            if(candidate > pLogwx[wnext0][i]){
                pLogwx[wnext0][i] = candidate;
                translation[wnext0][i]=w;
            }

            candidate = pLogwx[w][i-1] + pLogGaussian(wnext1,x) + log(ptransition[w].second);
            if(candidate > pLogwx[wnext1][i]){
                pLogwx[wnext1][i] = candidate;
                translation[wnext1][i]=w;
            }
        }
    }
    int curw, pmax=-9999999;
    for(int w=0; w<pstate.size(); w++){
        if(pLogwx[w][xtest.size()-1] > pmax){
            curw = w;
            pmax = pLogwx[w][xtest.size()-1];
        }
    }

    stack <int> st;
    st.push(curw);
    cout << curw << endl;
    for(int i = xtest.size()-1; i>0; i--){
        curw = translation[curw][i];
        st.push(curw);
        cout << curw << endl;
    }

    out.open("out.txt");
    curw= st.top();
    st.pop();
    string s = bitset<64>(curw).to_string();
    s = s.substr(64-n);

    out << s;
    while(!st.empty()){
        curw = st.top();
        st.pop();
        s = bitset<64>(curw).to_string();
        s = s.substr(64-1);
        out << s;
    }
    out.close();
}

int main()
{
    readConfig();
    init();
    train();
    generateTransmission();
    test();
    return 0;
}
