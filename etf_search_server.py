from flask import Flask, request, render_template, redirect, url_for
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import time
import random
import sys
import os

# 判斷 base_dir
if getattr(sys, 'frozen', False):
    base_dir = sys._MEIPASS
else:
    base_dir = os.path.abspath(".")

template_dir = os.path.join(base_dir, 'templates')

app = Flask(__name__, template_folder=template_dir)

PASSWORD = "8888"  # 設定的密碼

# 登入頁面
@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        password = request.form.get("password")
        if password == PASSWORD:
            # 登入成功，跳轉到查詢頁面，並將登入狀態以 URL 參數方式傳遞
            return redirect(url_for("search_etf", authenticated="true"))
        else:
            error = "❌ 密碼錯誤，請再試一次。"
            return render_template("login.html", error=error)
    
    return render_template("login.html")

# 查詢頁面
@app.route("/search", methods=["GET", "POST"])
def search_etf():
    # 檢查 URL 中的 authenticated 參數是否為 "true"
    authenticated = request.args.get("authenticated")
    if authenticated != "true":
        return redirect(url_for("login"))

    result = []
    error = ""
    etf = ""

    if request.method == "POST":
        etf = request.form["etf_code"].strip()

        chrome_options = Options()
        chrome_options.binary_location = "/usr/bin/chromium"
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-blink-features=AutomationControlled")
        chrome_options.add_argument("user-agent=Mozilla/5.0")

        try:
            from selenium.webdriver.chrome.service import Service
            service = Service("/usr/bin/chromedriver")  # Docker 裡 chromedriver 路徑
            driver = webdriver.Chrome(service=service, options=chrome_options)

            driver.get(f"https://www.wantgoo.com/stock/etf/{etf}/dividend-policy/ex-dividend")
            time.sleep(random.uniform(1, 2))
            driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            time.sleep(random.uniform(0.5, 1.5))

            # 檢查是否為無效代碼頁面（標題包含關鍵字）
            if "查無此代碼" in driver.title:
                error = "❌ ETF代碼錯誤或查無資料，請重新輸入。"
                driver.quit()
                return render_template("etf_search.html", result=result, etf=etf, error=error)

            rows = driver.find_elements(By.XPATH, "//tbody/tr")

            if not rows:
                error = "💡 ETF 無配息紀錄。"
            else:
                rows = rows[:5]
                for row in rows:
                    tds = row.find_elements(By.TAG_NAME, "td")
                    dividend = tds[1].text
                    ex_div_date = tds[2].text
                    before_price = tds[4].text
                    try:
                        after_price = round(float(before_price) - float(dividend), 2)
                    except:
                        after_price = ""
                    result.append({
                        "ex_date": ex_div_date,
                        "before_price": before_price,
                        "dividend": dividend,
                        "after_price": after_price
                    })

            driver.quit()

        except Exception as e:
            print(f"錯誤訊息：{e}")
            error = "❌ ETF代碼錯誤或查無資料，請重新輸入。"

    return render_template("etf_search.html", result=result, etf=etf, error=error)

if __name__ == "__main__":
    import os
    port = int(os.environ.get("PORT", 5000))  # 默认是 5000，但 Render 会传入一个真正的端口
    app.run(host="0.0.0.0", port=port, debug=True)
