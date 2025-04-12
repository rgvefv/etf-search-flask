# 使用更新版本的 python 映像
FROM python:3.10-slim

# 設定工作目錄
WORKDIR /app

# 複製 requirements.txt 並安裝依賴
COPY requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# 複製剩餘的應用程式代碼
COPY . /app/

# 設定環境變數
ENV FLASK_APP=app.py

# 開放容器端口
EXPOSE 5000

# 啟動應用程式
CMD ["flask", "run", "--host=0.0.0.0"]
