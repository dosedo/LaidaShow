

#define _CRT_SECURE_NO_WARNINGS
#define _PI 3.1415926

#include "post_process.h"

#include <iostream>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <cmath>
#include <algorithm>
#include <vector>
#include <queue>
#include "opencv2/opencv.hpp"

#define maxCCnum 5000

using namespace std;
using namespace cv;
class P {
public:
    int i, j;
    P(int i, int j) {
        this->i = i;
        this->j = j;
    }
    P() {
        i = j = 0;
    }
};

struct BD {
    int i, j, mark;
    BD(int i, int j, int m) {
        this->i = i;
        this->j = j;
        mark = m;
    }
    bool operator <(const BD& b) const {
        return mark > b.mark;
    }
};

class CC {
public:
    int mark, cnt;
    CC(int m, int c) {
        mark = m;
        cnt = c;
    }
    CC() {
        mark = 0;
        cnt = 0;
    }

    bool operator <(const CC& c) const {
        return cnt < c.cnt;
    }
};
class PostProcess {
public:

    void handle(char* srcDir, char* binDir, char* dstDir, int cnt);
    void handle(char* srcDir, char* binDir, char* dstDir, char* bgPath, int cnt);
private:
    int dx[4] = { 0,0,-1,1 };
    int dy[4] = { -1,1,0,0 };
    int h = 0, w = 0;
    int** mark;
    int** fg;

    void getCC(priority_queue<CC> &ccHeap);
    void getFg(priority_queue<CC> &ccHeap, vector<CC> &fgList);
    void getBorder(int step);
};




void PostProcess::handle(char* srcDir, char* binDir, char* dstDir, int cnt) {
	handle(srcDir, binDir, dstDir, NULL, cnt);
}

void PostProcess::handle(char* srcDir, char* binDir, char* dstDir, char* bgPath, int cnt) {
	char str[200];
	cv::Mat bgImg;
	bool changeBg = (bgPath != NULL);
	if(changeBg) bgImg = imread(bgPath);
	for (int t = 0;t < cnt;t++) {
		sprintf(str, "%s%02d.jpg", binDir, t);
		cv::Mat binImage = imread(str, 0);
		if (h != binImage.rows||w != binImage.cols) {
			h = binImage.rows;
			w = binImage.cols;
			fg = new int* [h];
			for (int i = 0; i < h; i++) fg[i] = new int[w];
			mark = new int* [h];
			for (int i = 0; i < h; i++) mark[i] = new int[w];
		}
		for (int i = 0;i < h;i++) {
			for (int j = 0; j < w; j++) {
				if (binImage.at<uchar>(i, j) > 225) fg[i][j] = 1;
				else fg[i][j] = 0;
				mark[i][j] = 0;
			}
		}
		priority_queue<CC> ccHeap;
		getCC(ccHeap);
		if (ccHeap.size() < 1) return;
		printf("%d--CC number:%d\n",t, (int)ccHeap.size());
		vector<CC> fgList;
		getFg(ccHeap, fgList);
		printf("%d--fg number:%d\n", t, (int)fgList.size());
		/*for (int i = 0;i < h;i++) {
			for (int j = 0;j < w;j++) {
				for (CC f : fgList) {
					if (mark[i][j] == f.mark) fg[i][j] = 1;
					else fg[i][j] = 0;
				}
			}
		}*/
		int fgSize = 0;
		sprintf(str, "%s%02d.jpg", srcDir, t);
		cv::Mat srcImg = imread(str);
		cv::Mat dstImg;
		if (changeBg) {
			Size dsize = Size(w, h);
			resize(bgImg, dstImg, dsize);
		}
		else dstImg = Mat(h, w, CV_8UC3, cv::Scalar::all(0xff));
		// 标记
		for (int i = 0;i < h;i++) {
			for (int j = 0;j < w;j++) {
				fg[i][j] = 0;
				for (CC f : fgList) {
					if (mark[i][j] == f.mark) {
						fg[i][j] = 1;
						fgSize++;
					}
				}
				mark[i][j] = 0;
			}
		}
		int maxStep = (int)(fgSize / 1.5e5 * 3 + 0.5);
		int half = maxStep / 2;
		printf("fgSize:%d step:%d\n",fgSize,maxStep);
		getBorder(maxStep);
        for (int i = half; i < h-half; i++) {
            for (int j = half; j < w-half; j++) {
//		for (int i = 0;i < h;i++) {
//			for (int j = 0;j < w;j++) {
				if (mark[i][j] != 0) { // 边缘
					int R = 0, G = 0, B = 0;
					for (int di = 0;di < maxStep;di++) {
						for (int dj = 0;dj < maxStep;dj++) {
							if (fg[i + di - half][j + dj - half]) {
								B += srcImg.at<Vec3b>(i + di - half, j + dj - half)[0];
								G += srcImg.at<Vec3b>(i + di - half, j + dj - half)[1];
								R += srcImg.at<Vec3b>(i + di - half, j + dj - half)[2];
							}
							else if (changeBg) {
								B += dstImg.at<Vec3b>(i + di - half, j + dj - half)[0];
								G += dstImg.at<Vec3b>(i + di - half, j + dj - half)[1];
								R += dstImg.at<Vec3b>(i + di - half, j + dj - half)[2];
							} 
							else {
								R += 0xff;
								G += 0xff;
								B += 0xff;
							}
						}
					}
					R /= maxStep * maxStep;
					G /= maxStep * maxStep;
					B /= maxStep * maxStep;
					dstImg.at<Vec3b>(i, j)[0] = B;
					dstImg.at<Vec3b>(i, j)[1] = G;
					dstImg.at<Vec3b>(i, j)[2] = R;
				}
				else {
					if (fg[i][j]) {
						dstImg.at<Vec3b>(i, j)[0] = srcImg.at<Vec3b>(i, j)[0];
						dstImg.at<Vec3b>(i, j)[1] = srcImg.at<Vec3b>(i, j)[1];
						dstImg.at<Vec3b>(i, j)[2] = srcImg.at<Vec3b>(i, j)[2];
					}
				}
			}
		}
		// 输出图像
		sprintf(str, "%s%02d.jpg", dstDir, t);
		cv::imwrite(str, dstImg);
		// 释放空间
		binImage.release();
		srcImg.release();
		dstImg.release();
	}
	for (int i = 0; i < h; ++i) {
		delete[] mark[i];
		mark[i] = NULL;
	}
	delete[] mark;
	for (int i = 0; i < h; ++i) {
		delete[] fg[i];
		fg[i] = NULL;
	}
	delete[] fg;

	if (changeBg) bgImg.release();
}

void PostProcess::getBorder(int step) {
	priority_queue<BD> q;
	for (int i = step;i < h - step;i++) {
		for (int j = step; j < w - step; j++) {
			if (fg[i][j] == 0 && (fg[i - 1][j] != 0 || fg[i][j - 1] != 0 || fg[i][j + 1] != 0 || fg[i + 1][j] != 0)) {
				q.push(BD(i, j, 1));
				mark[i][j] = 1;
			}
		}
	}
	while (!q.empty()) {
		BD p = q.top(); q.pop();
		int ui = p.i, uj = p.j;
		if (mark[ui][uj] > step) continue;
		for (int k = 0; k < 4; k++) {
			int vi = ui + dx[k], vj = uj + dy[k];
			if (vi < 0 || vi >= h || vj < 0 || vj >= w)
				continue;
			if (mark[vi][vj] != 0)
				continue;
			mark[vi][vj] = mark[ui][uj] + 1;
			q.push(BD(vi, vj, mark[vi][vj]));  // x  y
		}
	}
}
// 求连通分量
void PostProcess::getCC(priority_queue<CC> &ccHeap) {
	int ccNum = 0;
	for (int i = 0;i < h;i++) {
		for (int j = 0;j < w;j++) {
			if (fg[i][j] != 0 && mark[i][j] == 0) {
				queue<P> q;
				q.push(P(i, j));  // x  y
				mark[i][j] = ++ccNum;
				int cnt = 1;
				while (!q.empty()) {
					P p = q.front(); q.pop();
					int ui = p.i, uj = p.j;
					for (int k = 0;k < 4;k++) {
						int vi = ui + dx[k], vj = uj + dy[k];
						if (vi < 0 || vi >= h || vj < 0 || vj >= w) continue;
						if (fg[vi][vj] != 0 && mark[vi][vj] == 0) {
							q.push(P(vi, vj));
							mark[vi][vj] = ccNum;
							cnt++;
						}
					}
				}
				ccHeap.push(CC(ccNum, cnt));
			}
		}
	}
}
// 判断连通分量中的前景
void PostProcess::getFg(priority_queue<CC> &ccHeap, vector<CC> &fgList) {
	if (ccHeap.empty()) return;
	CC main = ccHeap.top(); ccHeap.pop();
	fgList.push_back(main);
	while (!ccHeap.empty()) {
		CC c = ccHeap.top(); ccHeap.pop();
		if (c.cnt < main.cnt / 3) break;
		else {
			double cy = 0.0, cx = 0.0, base = c.cnt;
			for (int i = 0; i < h; i++) {
				for (int j = 0; j < w; j++) {
					if (mark[i][j] == c.mark) {
						cy += i / base;
					}
				}
			}
			if (cy < 0.75 * h) fgList.push_back(c); // 不在底部1/4处
		}
	}
}


extern "C" {
    
    void getMaxCC(char *ori_path, char *seg_path, char *out_path,char *bg_path,int cnt) {
        
        PostProcess obj;
        obj.handle(ori_path, seg_path, out_path, bg_path, cnt);
    }
}
