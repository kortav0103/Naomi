# KỊCH BẢN THUYẾT TRÌNH BÁO CÁO ASSIGNMENT 01 (SPECIFICATION)
## DỰ ÁN: NAOMI — NỀN TẢNG ĐỌC TRUYỆN TRANH & GIẢI TRÍ ĐA GIÁC QUAN
### Thời lượng thuyết trình: 15 Phút | Phạm vi: Mục 1.1 đến 1.6 (Chuẩn Rubric Excellent 90–100%)

---

## BẢNG PHÂN BỔ THỜI GIAN VÀ CẤU TRÚC SLIDE (TIMELINE CHUẨN 15 PHÚT)

| STT Slide | Tiêu đề Slide | Nội dung Spec tương ứng | Thời lượng | Mốc thời gian |
| :---: | :--- | :---: | :---: | :---: |
| **Slide 01** | Giới thiệu dự án Naomi & Định vị đề tài | Tổng quan / Title | 0:45 | 00:00 - 00:45 |
| **Slide 02** | Bối cảnh thực tế & 7 Nỗi đau (Pain Points) của độc giả | **1.1** Problem Analysis | 1:15 | 00:45 - 02:00 |
| **Slide 03** | Chân dung người dùng (Personas) & Khảo sát thực tế ($N=4$) | **1.1** Elicitation & Personas | 1:15 | 02:00 - 03:15 |
| **Slide 04** | Phân tích đối thủ cạnh tranh & Đề xuất giá trị độc bản (UVP) | **1.1** Competitor Analysis | 1:00 | 03:15 - 04:15 |
| **Slide 05** | Phân loại yêu cầu chức năng theo chuẩn MoSCoW (FR-01 → FR-17) | **1.2** MoSCoW Prioritisation | 1:00 | 04:15 - 05:15 |
| **Slide 06** | Sơ đồ Use Case tổng thể & Phân hệ chức năng cốt lõi | **1.2** Use Case Diagram | 1:00 | 05:15 - 06:15 |
| **Slide 07** | Đặc tả Use Case chi tiết & Tiêu chí chấp nhận (Gherkin AC) | **1.2** Use Case Specs & AC | 1:00 | 06:15 - 07:15 |
| **Slide 08** | Khung chất lượng ISO/IEC 25010 & Ma trận NFR định lượng | **1.3** Measurable NFRs | 1:00 | 07:15 - 08:15 |
| **Slide 09** | Ràng buộc kỹ thuật di động chuyên biệt (Mobile Constraints) | **1.3** Mobile Constraints | 1:00 | 08:15 - 09:15 |
| **Slide 10** | Kiến trúc hệ thống phân tán đa tầng (System Context Architecture) | **1.4** Overall Architecture | 1:00 | 09:15 - 10:15 |
| **Slide 11** | Kiến trúc bên trong ứng dụng (In-App Clean Architecture & BLoC) | **1.4** In-App Clean Architecture | 1:00 | 10:15 - 11:15 |
| **Slide 12** | Luồng nghiệp vụ then chốt (Sequence Diagrams: Online & Dual Audio) | **1.4** Sequence Diagrams | 1:00 | 11:15 - 12:15 |
| **Slide 13** | Luận cứ khoa học lựa chọn Stack công nghệ (Tech Justification) | **1.4** Tech Stack Justification | 0:45 | 12:15 - 13:00 |
| **Slide 14** | Mô hình dữ liệu chuẩn hóa 3NF, ERD & Chiến lược đánh chỉ mục | **1.5** Data Model & ERD (3NF) | 0:45 | 13:00 - 13:45 |
| **Slide 15** | Chiến lược lưu trữ cục bộ 4 tầng & Hợp đồng API (MangaDex, Spotify) | **1.5** Storage & API Contracts | 0:45 | 13:45 - 14:30 |
| **Slide 16** | Hệ thống thiết kế UI/UX, Design Tokens & 4 Trạng thái màn hình | **1.6** Design System & States | 0:45 | 14:30 - 15:15 |
| **Slide 17** | Trình diễn Luồng người dùng, Clickable Prototype & Tổng kết | **1.6** User Flows & Prototype | 0:30 | 15:15 - 15:45 |

---

# CHI TIẾT TỪNG SLIDE: THIẾT KẾ TRỰC QUAN & KỊCH BẢN THUYẾT TRÌNH

---

## SLIDE 01: TITLE SLIDE — GIỚI THIỆU ĐỀ TÀI & ĐỊNH VỊ DỰ ÁN
* **Thời lượng:** 45 giây (00:00 - 00:45)
* **Mục tiêu đạt điểm:** Tạo ấn tượng mở đầu chuyên nghiệp, định vị rõ đề tài môn học thuộc nhóm "The Entertainment App".

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Background:** Nền tối AMOLED sang trọng (`#111116`), điểm xuyết vệt sáng màu tím oải hương (`#7066A6`) và xanh Spotify (`#1DB954`).
* **Tiêu đề chính (Headline Large):** **NAOMI — AMBIENT MANGA READER & ENTERTAINMENT PLATFORM**
* **Tiêu đề phụ (Subtitle):** Nền tảng Đọc truyện tranh Kỹ thuật số kết hợp Hệ thống Âm thanh Giải trí Kép (Dual Ambient Audio Engine)
* **Bố cục 2 cột:**
  - **Cột trái:** Thông tin học phần (Mobile Development Project), Giảng viên hướng dẫn (ThS. Phan Trần Minh Khuê), Nhóm sinh viên thực hiện, Ngày báo cáo.
  - **Cột phải:** Hình ảnh mockup điện thoại chạy app Naomi hiển thị giao diện Dark Mode đọc truyện kết hợp đĩa than/sóng nhạc Ambient đang phát.
* **Badges/Tag:** `Clean Architecture` | `Flutter & BLoC` | `MangaDex v5` | `Spotify Integration` | `Offline-First`.

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Kính chào thầy Minh Khuê và toàn thể các bạn. Hôm nay, nhóm chúng em xin phép được trình bày bản đặc tả yêu cầu và thiết kế kiến trúc hệ thống cho dự án **Naomi** — thuộc phân nhóm đề tài Ứng dụng Giải trí Đa dịch vụ (The Entertainment App).*  
>  
> *Khác biệt với các ứng dụng đọc truyện thông thường, Naomi được chúng em định vị là một **Nền tảng Giải trí Đa giác quan (Audio-Visual Platform)**. Ứng dụng giải quyết bài toán cốt lõi: kết hợp trải nghiệm đọc truyện tranh bản quyền mở chất lượng cao từ MangaDex với hệ sinh thái âm thanh giải trí kép gồm nhạc Lo-Fi offline nhúng sẵn và dịch vụ trực tuyến Spotify. Toàn bộ tài liệu đặc tả từ mục 1.1 đến 1.6 được nhóm chuẩn hóa khắt khe theo các tiêu chuẩn kỹ nghệ phần mềm quốc tế nhằm đảm bảo tính khả thi cao nhất cho giai đoạn hiện thực hóa A02."*

---

## SLIDE 02: [MỤC 1.1] BỐI CẢNH THỰC TẾ & 7 NỖI ĐAU CỦA ĐỘC GIẢ
* **Thời lượng:** 1 phút 15 giây (00:45 - 02:00)
* **Mục tiêu đạt điểm 1.1 (15 điểm):** Tuyên bố bài toán mạch lạc, phân tích chính xác các Pain Points thực tế dựa trên hành vi người dùng di động.

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.1 BỐI CẢNH BÀI TOÁN & 7 ĐIỂM NGHẼN TRẢI NGHIỆM (PAIN POINTS)**
* **Bố cục:** Chia làm 2 khối rõ ràng:
  - **Khối trên (Bối cảnh di động):** Độc giả trẻ đọc truyện tranh phân tán trong ngày (nghỉ trưa, trên xe buýt 4G, trước khi ngủ).
  - **Khối dưới (Lưới 7 thẻ Pain Points có icon trực quan):**
    1. 🚫 **Quảng cáo độc hại (Intrusive Ads):** Pop-up cờ bạc, video bật to tiếng giữa đêm.
    2. 🌐 **Rào cản ngôn ngữ:** Truyện quốc tế ra chương mới nhưng thiếu bản dịch tiếng Việt.
    3. 🔍 **Kho truyện phân tán & Khó tìm:** Không tìm được truyện khi chỉ có ảnh chụp màn hình.
    4. 📶 **Offline nghèo nàn:** Rớt 4G là app bị đứng hình; các app đối thủ khóa tính năng tải sau cổng nạp tiền.
    5. ⚡ **Giật lag khi cuộn:** Rớt khung hình (drop FPS) khi lướt qua 40–60 ảnh Webtoon lớn.
    6. 🎧 **Cảm xúc đơn điệu:** Chỉ có hình ảnh tĩnh, thiếu âm nhạc đồng điệu với bối cảnh truyện.
    7. 🔄 **Mất dữ liệu tiến trình:** Đổi máy hoặc cài lại app là mất sạch lịch sử và bookmark.

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Thưa thầy, hiện nay nhu cầu đọc truyện tranh trên thiết bị di động của giới trẻ là cực kỳ lớn. Tuy nhiên, qua khảo sát thực tế, độc giả đang phải chịu đựng 7 nỗi đau lớn:  
> Thứ nhất, **quảng cáo rác và độc hại**: các app lậu chèn dày đặc video cờ bạc tự bật tiếng, phá nát cảm xúc người đọc.  
> Thứ hai, **rào cản dịch thuật** khi các chương mới quốc tế chưa kịp dịch.  
> Thứ ba, **khó tìm truyện**: người dùng thấy ảnh đẹp trên mạng nhưng không có cách nào tìm ra tên truyện.  
> Thứ tư, **trải nghiệm ngoại tuyến tồi tệ**: đi xe buýt rớt mạng 4G là app lập tức bị đóng băng, còn các app chính thống thì bắt nạp tiền đắt đỏ mới cho tải.  
> Thứ năm, **hiệu năng cuộn kém tối ưu**, giật lag khi cuộn chương dài.  
> Thứ sáu, trải nghiệm giác quan đơn điệu, thiếu âm nhạc hợp vibe.  
> Và cuối cùng là **thiếu đồng bộ đám mây**, làm mất toàn bộ tủ sách khi đổi thiết bị. Đây chính là lý do Naomi ra đời để giải quyết triệt để các vấn đề này."*

---

## SLIDE 03: [MỤC 1.1] BẰNG CHỨNG KHẢO SÁT & CHÂN DUNG NGƯỜI DÙNG
* **Thời lượng:** 1 phút 15 giây (02:00 - 03:15)
* **Mục tiêu đạt điểm 1.1 (15 điểm):** Trình diễn bằng chứng thu thập yêu cầu thực tế (Requirements Elicitation Evidence) từ file khảo sát người dùng thật và 2 Personas điển hình.

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.1 BẰNG CHỨNG KHẢO SÁT THỰC TẾ & CHÂN DUNG NGƯỜI DÙNG (PERSONAS)**
* **Bố cục 2 phần đối sánh:**
  - **Phần trái — Dữ liệu khảo sát thực chứng ($N=4$, minh chứng đính kèm `khảo sát 4 người.pdf`):**
    - 📊 **100% người dùng** coi quảng cáo video/cá cược là nỗi ức chế lớn nhất.
    - 🎵 **100% người dùng** có thói quen nghe nhạc khi đọc truyện (Điểm hứng thú Ambient Audio đạt **3.75/5.0**, 75% cho 4/5).
    - 💾 **75% người dùng** yêu cầu tính năng tự lưu lịch sử đọc đến từng trang.
    - 📥 **50% người dùng** bức xúc vì rớt mạng 4G bị đứng hình và không cho tải offline.
  - **Phần phải — 2 Personas đại diện rõ nét:**
    - 👤 **Kiệt (21t, Redmi Note 12 AMOLED):** Đại diện nhóm đọc đêm muộn (22h30–00h30), cực ghét quảng cáo nổ to tiếng, cần Dark Mode thuần túy và nhạc Lo-Fi thư giãn không nóng máy.
    - 👤 **Thảo (20t, Galaxy A54 4G):** Đại diện nhóm đọc tranh thủ trên xe buýt/giờ giải lao, cần tải 1-chạm đọc offline khi sóng yếu và tìm kiếm truyện bằng hình ảnh.

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Để không đưa ra các giả định cảm tính, nhóm đã thực hiện khảo sát bán cấu trúc trên mẫu độc giả thực tế. Kết quả trả về rất ấn tượng và có tính đồng thuận cao:  
> **100% người tham gia** khẳng định quảng cáo rác là điểm gây ức chế nhất, và **100%** đều có thói quen nghe nhạc khi đọc truyện. Điểm đánh giá sự hứng thú với tính năng Ambient Audio tích hợp đạt 3.75 trên 5 điểm.  
>  
> Từ dữ liệu này, nhóm đúc kết thành 2 Personas điển hình:  
> Bạn **Kiệt** đại diện cho nhóm đọc đêm muộn: cần giao diện Dark Mode bảo vệ mắt, không quảng cáo và có sẵn nhạc nền Lo-Fi / Spotify trong app để không phải mở song song 2 ứng dụng gây nóng máy tụt pin.  
> Bạn **Thảo** đại diện cho độc giả hay di chuyển: thường xuyên bị chập chờn 4G trên xe buýt nên bắt buộc ứng dụng phải có cơ chế tải ngoại tuyến 1-chạm hoàn toàn miễn phí và tự động lưu vết chính xác từng trang đang đọc dở."*

---

## SLIDE 04: [MỤC 1.1] ĐỐI THỦ CẠNH TRANH & ĐỀ XUẤT GIÁ TRỊ ĐỘC BẢN (UVP)
* **Thời lượng:** 1 phút (03:15 - 04:15)
* **Mục tiêu đạt điểm 1.1 (15 điểm):** Bảng đối sánh định lượng/định tính với LINE Webtoon & MangaToon, làm bật Unique Value Proposition của Naomi.

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.1 PHÂN TÍCH ĐỐI THỦ & ĐỀ XUẤT GIÁ TRỊ ĐỘC BẢN (UVP)**
* **Bảng so sánh 3 bên (Highlight cột NAOMI màu tím nổi bật):**

| Tiêu chí so sánh | LINE Webtoon | MangaToon | **NAOMI (Dự án của nhóm)** |
| :--- | :---: | :---: | :---: |
| **Mức độ Quảng cáo** | Video bắt buộc, Daily Pass | Banner/Pop-up web cờ bạc dày đặc | 🟢 **100% Không quảng cáo rác** |
| **Âm thanh Ambient** | Không có (chỉ vài bộ trả phí) | Hoàn toàn không có | 🟢 **Hệ thống âm thanh kép: Lo-Fi + Spotify** |
| **Tải Offline** | Bắt mua xu, tự xóa sau 30 ngày | Khóa sau cổng nạp tiền VIP | 🟢 **Tải 1-chạm, lưu SQLite miễn phí** |
| **Lưu vết từng trang** | Có | Có | 🟢 **Tự động lưu chính xác số trang (Page)** |
| **Chế độ đọc** | Chỉ hỗ trợ cuộn dọc | Cuộn dọc hạn chế | 🟢 **Linh hoạt: Cuộn dọc Webtoon & Lật Manga** |
| **Nguồn dữ liệu** | Độc quyền đóng | Độc quyền đóng | 🟢 **MangaDex API mở + Supabase Cloud** |

* **Hộp UVP (Khung viền vàng):**  
  *"Naomi là ứng dụng đọc truyện di động đầu tiên kết hợp trải nghiệm đọc mượt mà 60 FPS, 100% không quảng cáo, tải offline miễn phí với hệ sinh thái âm thanh giải trí kép Lo-Fi & Spotify."*

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Khi đặt Naomi lên bàn cân với hai ứng dụng hàng đầu hiện nay là LINE Webtoon và MangaToon, điểm khác biệt của chúng em thể hiện rất rõ ràng:  
> Các app thương mại hiện nay hoặc cài cắm quảng cáo độc hại, hoặc thương mại hóa quá mức khi khóa tính năng đọc offline sau các cổng nạp tiền và giới hạn thời gian lưu 30 ngày.  
>  
> Naomi giải quyết triệt để bằng 3 giá trị độc bản (UVP):  
> Một là trải nghiệm **hoàn toàn sạch bóng quảng cáo**.  
> Hai là kiến trúc **Offline-First**, cho phép tải chương về máy lưu trữ SQLite vĩnh viễn miễn phí.  
> Và ba là **Dual Ambient Audio** — vừa có nhạc Lo-Fi nghe không tốn data, vừa có Spotify Streaming bản quyền ngay trong app mà đối thủ hoàn toàn không có."*

---

## SLIDE 05: [MỤC 1.2] PHÂN LOẠI YÊU CẦU CHỨC NĂNG THEO CHUẨN MOSCOW
* **Thời lượng:** 1 phút (04:15 - 05:15)
* **Mục tiêu đạt điểm 1.2 (20 điểm):** Phân chia phạm vi dự án rõ ràng, cam kết nghiệm thu theo ma trận MoSCoW chuẩn kỹ nghệ phần mềm.

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.2 ĐẶC TẢ YÊU CẦU CHỨC NĂNG & PHÂN LOẠI MOSCOW (FR-01 → FR-17)**
* **Bố cục 4 khối màu MoSCoW:**
  - 🔴 **MUST-HAVE (11 Chức năng sống còn — Nghiệm thu 100% trong A02):**
    - `FR-01` Khám phá thịnh hành (Trending/Featured) qua MangaDex API.
    - `FR-02` Tìm kiếm truyện & Bộ lọc thể loại đa điều kiện (Debounce 400ms).
    - `FR-03` Xem chi tiết tác phẩm & Danh mục chương tiếng Anh (`en`).
    - `FR-04` Trình đọc Webtoon cuộn dọc mượt 60 FPS (LRU Image Cache).
    - `FR-06` Tự động lưu vết tiến trình đọc đến từng trang (`last_page_read`).
    - `FR-07` Đọc tiếp nhanh 1-chạm (Continue Reading).
    - `FR-08` Tải chapter đọc ngoại tuyến (Tải đồng thời 4 ảnh, ghi SQLite).
    - `FR-09` Trình đọc ngoại tuyến độc lập không cần Internet.
    - `FR-11` Quản lý tủ sách yêu thích cá nhân (Bookmarks).
    - `FR-12` Quản lý dung lượng & Xóa bộ nhớ đệm (Storage Cleaner).
    - `FR-14` Xác thực Supabase Auth & Chế độ Khách (Guest Mode).
  - 🟡 **SHOULD-HAVE (3 Chức năng nâng cấp giá trị trải nghiệm):**
    - `FR-05` Trình đọc Manga lật trang ngang (LTR & RTL Nhật Bản).
    - `FR-10` Dịch vụ Âm thanh Giải trí Kép: Lo-Fi offline + Spotify Streaming.
    - `FR-15` Giao diện nền tối thuần khiết Dark Mode AMOLED (`#111116`).
  - 🔵 **COULD-HAVE (Lộ trình tương lai v2):** `FR-16` Tìm kiếm bằng ảnh & Dịch AI on-device.
  - ⚫ **WON'T-HAVE:** `FR-17` Cổng thanh toán nạp tiền/VIP (Cam kết miễn phí phi lợi nhuận).

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Thưa thầy, bước sang Mục 1.2 về Yêu cầu Chức năng, nhóm đã chuẩn hóa toàn bộ 17 yêu cầu chức năng từ FR-01 đến FR-17 theo phương pháp luận MoSCoW:  
> Nhóm cam kết **11 chức năng Must-Have** sẽ được nghiệm thu đầy đủ 100% ở Assignment 02, bao gồm luồng khám phá MangaDex, trình đọc Webtoon 60 FPS, cơ chế tự động lưu trang đọc dở, tải ngoại tuyến SQLite, quản lý tủ sách và hệ thống xác thực Supabase song hành cùng Chế độ Khách.  
>  
> Bên cạnh đó, **3 chức năng Should-Have** làm nên bản sắc của Naomi gồm chế độ đọc Manga lật ngang, hệ thống âm thanh kép Lo-Fi/Spotify và Dark Mode AMOLED cũng được thiết kế hoàn thiện.  
> Các tính năng AI nặng về chi phí API và hạ tầng được nhóm xếp vào Could-Have cho lộ trình v2 để tránh gây nợ kỹ thuật cho phiên bản A02."*

---

## SLIDE 06: [MỤC 1.2] SƠ ĐỒ USE CASE TỔNG THỂ & PHÂN HỆ CHỨC NĂNG
* **Thời lượng:** 1 phút (05:15 - 06:15)
* **Mục tiêu đạt điểm 1.2 (20 điểm):** Sơ đồ Use Case tổng thể chuẩn UML, làm rõ 4 Tác nhân (Actors) và 3 Phân hệ chức năng cốt lõi.

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.2 SƠ ĐỒ USE CASE TỔNG THỂ (GLOBAL USE CASE DIAGRAM)**
* **Hình ảnh trung tâm:** Sơ đồ Use Case Diagram vẽ lại trực quan:
  - **4 Tác nhân (Actors):**
    - 👤 `End-User (Độc giả)`: Tác nhân chính.
    - ☁️ `MangaDex REST API`: Hệ thống ngoại vi cung cấp dữ liệu truyện.
    - 🎵 `Spotify Web API`: Hệ thống ngoại vi cung cấp nhạc trực tuyến.
    - 🔐 `Supabase Backend`: Dịch vụ xác thực đám mây.
    - 💾 `SQLite & Local Storage`: Thành phần lưu trữ nội bộ phục vụ Offline-First.
  - **3 Phân hệ Use Case (3 Subsystems đóng khung rõ ràng):**
    1. *Phân hệ Khám phá & Tìm kiếm (UC01 → UC04):* Trending, Search, Detail, Category Filter.
    2. *Phân hệ Trình đọc & Đa giác quan (UC05 → UC09):* Online Reader, Mode Switch, Dual Audio, Auto-save Progress, Volume/Track Control.
    3. *Phân hệ Tủ sách & Ngoại tuyến (UC10 → UC14):* Favorites, Offline Download, Local Reader, Storage Clear, Supabase/Guest Auth.

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Trên màn hình là Sơ đồ Use Case Tổng thể của hệ thống Naomi. Kiến trúc tương tác được phân định rõ ràng giữa tác nhân chính là **Độc giả (End-User)** với 3 dịch vụ đám mây bên ngoài gồm MangaDex, Spotify, Supabase và tầng lưu trữ cục bộ SQLite.  
>  
> Toàn bộ nghiệp vụ được phân rã thành **3 phân hệ độc lập có độ gắn kết cao**:  
> Phân hệ 1 là **Khám phá & Tìm kiếm** với cơ chế tải phân trang vô hạn và tìm kiếm đa tiêu chí.  
> Phân hệ 2 là **Trình đọc & Âm thanh Đa giác quan** — nơi tích hợp trình đọc đa chế độ kết hợp với điều khiển âm thanh nền song song.  
> Phân hệ 3 là **Tủ sách & Lưu trữ Ngoại tuyến**, đảm bảo dữ liệu của độc giả luôn sẵn sàng ngay cả khi ngắt toàn bộ kết nối mạng."*

---

## SLIDE 07: [MỤC 1.2] ĐẶC TẢ USE CASE CHI TIẾT & TIÊU CHÍ CHẤP NHẬN (AC)
* **Thời lượng:** 1 phút (06:15 - 07:15)
* **Mục tiêu đạt điểm 1.2 (20 điểm):** Minh chứng đặc tả Use Case chi tiết có Tiền điều kiện, Hậu điều kiện, Luồng ngoại lệ và Tiêu chí chấp nhận kiểm thử Gherkin (Given-When-Then).

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.2 ĐẶC TẢ USE CASE CỐT LÕI & TIÊU CHÍ CHẤP NHẬN (ACCEPTANCE CRITERIA)**
* **Bố cục 2 cột thể hiện trường hợp điển hình: UC-08 (Tải chapter ngoại tuyến) & UC-06 (Tự động lưu vết tiến trình):**
  - **Cột trái — Cấu trúc đặc tả Use Case chuẩn nghiệp vụ:**
    - *Tác nhân:* Độc giả (Đã đăng nhập hoặc Chế độ Khách).
    - *Tiền điều kiện:* Thiết bị có kết nối mạng, dung lượng bộ nhớ trống $\ge 50\text{ MB}$.
    - *Luồng chính (Main Flow):* Chọn tải $\rightarrow$ Khởi tạo hàng đợi 4 luồng $\rightarrow$ Tải ảnh vào bộ nhớ trong $\rightarrow$ Ghi metadata vào SQLite $\rightarrow$ Báo thành công.
    - *Luồng ngoại lệ (Exceptions):* Rớt mạng giữa chừng $\rightarrow$ Tự động Retry 3 lần $\rightarrow$ Rollback transaction SQLite không để dữ liệu rác.
  - **Cột phải — Tiêu chí chấp nhận kiểm thử dạng Gherkin (Testable Acceptance Criteria):**
    - `Scenario 1: Tự động ghi nhớ trang đọc dở`
      - **GIVEN:** Độc giả đang đọc Chapter 1 bộ truyện "Chainsaw Man" đến Trang 15.
      - **WHEN:** Độc giả vuốt thoát app hoặc chuyển sang màn hình khác.
      - **THEN:** Hệ thống ghi `last_page_read = 15` vào bảng `reading_history`. Khi mở lại, nút "Continue Reading" dẫn ngay tới đúng Trang 15 trong $< 50\text{ ms}$.

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Để phục vụ làm baseline nghiệm thu trực tiếp cho Assignment 02, từng Use Case trong tài liệu spec đều được chúng em đặc tả chi tiết từ Tiền điều kiện, Luồng chính, Luồng phụ đến Kịch bản phục hồi lỗi (Exception Flow).  
>  
> Đặc biệt, mỗi Use Case đều đi kèm các **Tiêu chí chấp nhận kiểm thử (Acceptance Criteria)** viết theo định dạng chuẩn công nghiệp Gherkin: Given - When - Then.  
> Ví dụ với tính năng lưu vết tiến trình đọc: Khi người dùng cuộn đến trang 15 và thoát app, hệ thống cam kết ghi nhận chính xác `last_page_read = 15` vào SQLite. Khi mở lại, app kích hoạt trạng thái 'Continue Reading' và nhảy thẳng đến đúng trang 15 mà không mất thời gian tải lại từ đầu. Mọi tiêu chí này đều có thể tự động hóa thành Unit Test và Integration Test ở giai đoạn sau."*

---

## SLIDE 08: [MỤC 1.3] KHUNG ISO/IEC 25010 & MA TRẬN NFR ĐỊNH LƯỢNG
* **Thời lượng:** 1 phút (07:15 - 08:15)
* **Mục tiêu đạt điểm 1.3 (10 điểm):** Toàn bộ NFR được định lượng bằng chỉ số đo lường (Metrics), ngưỡng chấp nhận (Targets) và công cụ đo lường tiêu chuẩn theo chuẩn ISO/IEC 25010.

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.3 YÊU CẦU PHI CHỨC NĂNG ĐỊNH LƯỢNG THEO CHUẨN ISO/IEC 25010**
* **Khung phương pháp luận:** 5 trụ cột chất lượng (Hiệu năng, Tin cậy, Bảo mật, Tiện dụng, Ràng buộc di động).
* **Bảng Ma trận NFR định lượng (Quantitative NFR Matrix):**

| Mã NFR | Tiêu chí kỹ thuật | Chỉ số đo lường (Metric) | Ngưỡng chấp nhận (Acceptance Target) | Công cụ kiểm thử |
| :---: | :--- | :--- | :--- | :---: |
| **NFR-01** | **Thời gian khởi động** | Cold Start / Warm Start | Cold: $\le \mathbf{1500\text{ ms}}$ \| Warm: $\le \mathbf{400\text{ ms}}$ | Flutter DevTools |
| **NFR-02** | **Độ trễ phản hồi API** | Request to Render finish | API: $\le \mathbf{1200\text{ ms}}$ \| Cache hit: $\le \mathbf{50\text{ ms}}$ | Network Profiler |
| **NFR-03** | **Tốc độ khung hình** | FPS khi cuộn 40 trang ảnh | Ổn định $\ge \mathbf{55\text{ FPS}}$ (Tỷ lệ drop frame $\le 1.5\%$) | Performance Overlay |
| **NFR-04** | **Truy vấn SQLite** | Thời gian đọc/ghi DB | Ghi vết đọc: $\le \mathbf{10\text{ ms}}$ \| Đọc Bookmarks: $\le \mathbf{20\text{ ms}}$ | StopWatch Benchmark |
| **NFR-05** | **Tiêu thụ RAM** | Bộ nhớ chiếm dụng tối đa | RAM trung bình $\le \mathbf{130\text{ MB}}$ \| Peak $\le \mathbf{190\text{ MB}}$ | Memory Profiler |
| **NFR-06** | **Tỷ lệ Crash do OOM** | Out-Of-Memory Crash Rate | $\mathbf{0\%}$ (Tự động giải phóng cache ảnh ẩn) | Crashlytics / Stress |

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Thưa thầy, ở Mục 1.3, nhóm tuân thủ nghiêm ngặt chuẩn quốc tế **ISO/IEC 25010**. Chúng em loại bỏ hoàn toàn các mô tả mơ hồ như 'app chạy nhanh' hay 'giao diện đẹp', mà thay bằng các **chỉ số kỹ thuật có thể đo lường định lượng chính xác**:  
> Thứ nhất, **Thời gian khởi động Cold Start** phải dưới 1.5 giây thông qua cơ chế tiêm phụ thuộc lười (Lazy Injection).  
> Thứ hai, chỉ số sống còn của một app đọc truyện là **Tốc độ khung hình khi cuộn**: Naomi cam kết duy trì ổn định trên **55 FPS**, tỷ lệ rớt khung hình dưới 1.5% nhờ sử dụng danh sách ảo hóa `ListView.builder` kết hợp bộ nhớ đệm đồ họa `cacheExtent: 2500`.  
> Thứ ba, mức chiếm dụng **RAM không vượt quá 190 MB**, đảm bảo tỷ lệ crash tràn RAM (OOM) bằng **0%** trên các dòng máy tầm trung như Redmi Note 12."*

---

## SLIDE 09: [MỤC 1.3] RÀNG BUỘC KỸ THUẬT DI ĐỘNG CHUYÊN BIỆT
* **Thời lượng:** 1 phút (08:15 - 09:15)
* **Mục tiêu đạt điểm 1.3 (10 điểm):** Giải quyết sâu các đặc tính phần cứng di động: Battery drain, Network flakiness, Hardware-backed Security và Quyền hạn tối thiểu.

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.3 CÁC RÀNG BUỘC KỸ THUẬT DI ĐỘNG CHUYÊN BIỆT (MOBILE CONSTRAINTS)**
* **Bố cục 4 thẻ kỹ thuật:**
  - 🔋 **Tối ưu Năng lượng & Màn hình AMOLED (NFR-13):**
    - Giao diện Dark Mode thuần đen `#111116` giúp tắt điểm ảnh OLED, tiết kiệm hơn 40% pin khi đọc ban đêm.
    - Quản lý Wakelock thông minh: Giữ sáng màn hình khi đang đọc, tự động nhả khóa sau 5 phút không chạm để chống cạn pin.
  - 📶 **Chính sách Mạng yếu & Data Saver (NFR-07 & NFR-14):**
    - Tự động nhận diện kết nối qua `connectivity_plus`.
    - Chế độ Tiết kiệm dữ liệu (Data Saver): Chuyển sang tải ảnh nén chất lượng tiêu chuẩn (Data-saver format) giúp giảm 65% băng thông 4G.
    - Cơ chế Exponential Backoff tự động thử lại khi rớt mạng với Timeout 12s.
  - 🔐 **Bảo mật Phần cứng & Không Cleartext HTTP (NFR-09 & NFR-10):**
    - Sử dụng `flutter_secure_storage` bọc chip phần cứng **Android Keystore** và **iOS Keychain** (Mã hóa AES-256 GCM) để lưu JWT Token.
    - Cấm 100% kết nối HTTP thường qua cấu hình `usesCleartextTraffic = false`.
  - 📱 **Chính sách Quyền hạn Tối thiểu (Principle of Least Privilege):**
    - Không xin bất kỳ quyền nhạy cảm nào (Danh bạ, Vị trí, SMS). Chỉ sử dụng quyền Internet và Foreground Service cho Audio.

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Để ứng dụng hoạt động bền bỉ trong môi trường di động thực tế, nhóm đã giải quyết 4 ràng buộc phần cứng khắt khe:  
> Về **pin và hiển thị**: Giao diện AMOLED Pure Black không chỉ giúp bạn Kiệt đọc truyện đêm không mỏi mắt, mà còn tắt hoàn toàn bóng LED, giảm 40% mức tiêu thụ năng lượng.  
> Về **mạng viễn thông**: Chế độ Data Saver tự động yêu cầu MangaDex trả về ảnh nén tối ưu, tiết kiệm 65% dung lượng 4G cho bạn Thảo khi đi xe buýt.  
> Về **an toàn thông tin**: Tuyệt đối không lưu token vào SharedPreferences dưới dạng text thuần dễ bị trích xuất khi root máy, mà sử dụng chip bảo mật phần cứng qua `flutter_secure_storage` với chuẩn mã hóa AES-256.  
> Đồng thời, Naomi tuân thủ nguyên tắc Quyền hạn Tối thiểu, chỉ xin duy nhất quyền kết nối mạng cơ bản."*

---

## SLIDE 10: [MỤC 1.4] KIẾN TRÚC HỆ THỐNG PHÂN TÁN ĐA TẦNG
* **Thời lượng:** 1 phút (09:15 - 10:15)
* **Mục tiêu đạt điểm 1.4 (20 điểm):** Sơ đồ ngữ cảnh hệ thống (System Context Diagram) phân định ranh giới giữa Client di động, Cloud Backend và dịch vụ bên thứ ba.

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.4 KIẾN TRÚC TỔNG THỂ HỆ THỐNG (SYSTEM CONTEXT ARCHITECTURE)**
* **Sơ đồ phân tầng tổng thể (System Context Diagram):**
  - **Tầng 1 — Dịch vụ Đám mây (Cloud & External Services Tier):**
    - `MangaDex REST API v5`: Quản lý kho truyện, metadata, chapter feed.
    - `MangaDex At-Home CDN Network`: Mạng lưới máy chủ phân phối ảnh toàn cầu.
    - `Spotify Web API & Platform`: Quản lý streaming và danh sách phát.
    - `Supabase Cloud Platform`: Xác thực tài khoản chuẩn SOC2 Type II.
  - **Giao thức kết nối:** HTTPS / TLS 1.3 mã hóa đầu cuối.
  - **Tầng 2 — Ứng dụng Di động Khách (Naomi Client Mobile App):**
    - 4 Khối chức năng: *Presentation (UI/BLoC)*, *Domain (UseCases/Entities)*, *Data (Repos/DataSources)* và *Core Platform Services (Dio, Dual Audio Engine, Theme)*.
  - **Tầng 3 — Tầng Lưu trữ Cục bộ (Local Persistence Tier - Offline First):**
    - `SQLite Engine (naomi.db)`: Lưu trữ dữ liệu quan hệ 3NF.
    - `Encrypted Keystore`: Lưu token bảo mật.
    - `Local File System`: Thư mục lưu ảnh đã tải và cache.

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Thưa thầy, bước sang Mục 1.4 về Thiết kế Kiến trúc, Naomi được xây dựng theo mô hình **Kiến trúc Phân tán Đa tầng (Distributed Multi-Tier Architecture)** lấy triết lý **Offline-First** làm trọng tâm.  
>  
> Như thể hiện trên sơ đồ bối cảnh:  
> Ứng dụng Client giao tiếp với 3 nền tảng đám mây độc lập qua giao thức bảo mật TLS 1.3: lấy kho truyện từ MangaDex, stream nhạc từ Spotify và xác thực phiên qua Supabase.  
> Điểm cốt lõi là Client không bao giờ phụ thuộc 100% vào mạng. Bên dưới ứng dụng là một **Tầng Lưu trữ Cục bộ ba thành phần** gồm SQLite cho dữ liệu quan hệ, Thư mục máy cho các tệp hình ảnh tải về, và Keystore mã hóa cho thông tin bảo mật. Nhờ thiết kế này, người dùng vẫn có thể đọc truyện trơn tru ngay cả khi ngắt hoàn toàn kết nối đám mây."*

---

## SLIDE 11: [MỤC 1.4] KIẾN TRÚC BÊN TRONG ỨNG DỤNG (CLEAN ARCHITECTURE & BLOC)
* **Thời lượng:** 1 phút (10:15 - 11:15)
* **Mục tiêu đạt điểm 1.4 (20 điểm):** Phân tích sâu Clean Architecture 3 tầng (Presentation, Domain, Data), nguyên lý Đảo ngược Phụ thuộc (DIP) và mô hình quản lý trạng thái BLoC.

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.4 KIẾN TRÚC BÊN TRONG ỨNG DỤNG (IN-APP CLEAN ARCHITECTURE & BLOC)**
* **Sơ đồ 3 tầng Clean Architecture theo chuẩn Uncle Bob:**
  - 🎨 **Presentation Layer (Tầng Trình diễn):**
    - Gồm các Widgets (Material 3), Screens và **BLoC Controllers** (`ComicBloc`, `ReaderBloc`, `AuthBloc`, `LibraryBloc`).
    - Quản lý trạng thái theo luồng dữ liệu 1 chiều (Unidirectional Data Flow): `Event -> BLoC -> State`.
  - 🧠 **Domain Layer (Tầng Nghiệp vụ Cốt lõi — Pure Dart, 0% Third-party):**
    - Chứa các `Use Cases` nghiệp vụ độc lập (`GetTrendingComics`, `DownloadChapter`, `SaveReadingProgress`).
    - Chứa các `Entities` thuần túy và Định nghĩa Interface (`Repositories Contracts`).
  - 💾 **Data Layer (Tầng Dữ liệu):**
    - `Repository Implementations`: Điều phối luồng dữ liệu Cache-First.
    - `Data Sources`: Phân tách rành mạch giữa `RemoteDataSource` (Dio, Supabase) và `LocalDataSource` (SQLite, SecureStorage).
* **Khung Nguyên lý DIP & Service Locator:**
  - Áp dụng nguyên lý SOLID - **Dependency Inversion Principle (DIP)**: Tầng Domain không phụ thuộc vào Data, mà Data phải phụ thuộc ngược lại vào Domain thông qua Interface.
  - Toàn bộ dịch vụ được tiêm phụ thuộc thông qua `GetIt` Service Locator, giúp code dễ dàng viết Unit Test độc lập.

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Đi sâu vào cấu trúc bên trong ứng dụng, chúng em áp dụng chuẩn mực **Clean Architecture** kết hợp cùng mô hình quản lý trạng thái phản ứng **BLoC (Business Logic Component)**:  
>  
> Kiến trúc được chia tách trách nhiệm thành 3 tầng nghiêm ngặt:  
> Tầng **Domain** là trái tim của hệ thống, được viết bằng Dart thuần túy, tuyệt đối không phụ thuộc vào bất kỳ thư viện UI hay framework bên ngoài nào. Mọi quy tắc nghiệp vụ đều nằm gọn trong các Use Case.  
> Tầng **Data** chịu trách nhiệm hiện thực hóa các Interface do Domain định nghĩa theo nguyên lý **Đảo ngược Phụ thuộc (DIP)**. Nó triển khai chính sách Cache-First: luôn kiểm tra dữ liệu trong SQLite trước khi gọi API mạng.  
> Và tầng **Presentation** chỉ nhận State từ BLoC để vẽ giao diện. Nhờ luồng dữ liệu một chiều này, hệ thống loại bỏ hoàn toàn các lỗi xung đột trạng thái và cho phép viết Unit Test độc lập cho từng hàm nghiệp vụ."*

---

## SLIDE 12: [MỤC 1.4] BIỂU ĐỒ TUẦN TỰ CHO CÁC LUỒNG NGHIỆP VỤ CHÍNH
* **Thời lượng:** 1 phút (11:15 - 12:15)
* **Mục tiêu đạt điểm 1.4 (20 điểm):** Trình diễn 2 biểu đồ tuần tự (Sequence Diagrams) phức tạp: Luồng đọc truyện trực tuyến (Cache-First) và Luồng Âm thanh Kép (Dual Audio Engine & Audio Focus).

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.4 BIỂU ĐỒ TUẦN TỰ CHO CÁC LUỒNG NGHIỆP VỤ THEN CHỐT**
* **Bố cục 2 sơ đồ Sequence Diagram rút gọn:**
  - **Sơ đồ 1 — Luồng Đọc truyện trực tuyến (Online Reader with Cache-First):**
    - `User` $\rightarrow$ `ReaderScreen` $\rightarrow$ `ReaderBloc` $\rightarrow$ `ComicRepository` $\rightarrow$ `LocalDatabase` (Kiểm tra cache trang) $\rightarrow$ Nếu chưa có $\rightarrow$ `DioClient` $\rightarrow$ `MangaDex@Home CDN` $\rightarrow$ Trả về ảnh $\rightarrow$ Lưu cache bộ nhớ $\rightarrow$ Render Widget 60 FPS.
  - **Sơ đồ 2 — Luồng Âm thanh Kép & Quản lý Audio Focus (Dual Ambient Audio Engine):**
    - Thể hiện sự chuyển đổi độc quyền `switchMode()`: Khi bật Lo-Fi offline thì tự ngắt Spotify; khi bật Spotify Connect thì tự dừng Lo-Fi.
    - Thể hiện cơ chế bắt sự kiện gián đoạn phần cứng `interruptionEvent` từ `audio_session`: Tự động tạm dừng nhạc khi có cuộc gọi điện thoại đến và tiếp tục sau khi kết thúc cuộc gọi.
    - Thu nhỏ thành `FloatingMiniPlayer` neo ở đáy màn hình khi độc giả thoát ra màn hình chính.

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Để chứng minh tính khả thi của thiết kế, nhóm đã xây dựng 4 biểu đồ tuần tự chi tiết. Trên slide là hai luồng nghiệp vụ phức tạp nhất:  
>  
> Ở luồng **Đọc truyện**: Khi người dùng mở một chapter, BLoC sẽ yêu cầu Repository kiểm tra dữ liệu trang trong SQLite và bộ nhớ đệm trước. Nếu đã tải về, hệ thống nạp ngay lập tức chỉ trong 10ms. Nếu chưa, Dio Client sẽ gọi song song đến MangaDex CDN và lưu đệm ngay khi ảnh về máy.  
>  
> Ở luồng **Âm thanh Giải trí Kép**: Dịch vụ `AmbientAudioService` kiểm soát việc chuyển đổi nguồn phát độc quyền giữa Lo-Fi nội bộ và Spotify Web API để không xảy ra xung đột CPU.  
> Đặc biệt, hệ thống xử lý sâu đến cấp phần cứng OS: nếu người dùng đang đọc truyện nghe nhạc mà có **cuộc gọi đến**, `AudioSession` sẽ lập tức bắt sự kiện gián đoạn và tạm dừng phát nhạc ngay để không làm phiền người dùng. Khi chuyển màn hình, trình phát sẽ tự động thu nhỏ thành Floating Mini-Player."*

---

## SLIDE 13: [MỤC 1.4] LUẬN CỨ KHOA HỌC LỰA CHỌN STACK CÔNG NGHỆ
* **Thời lượng:** 45 giây (12:15 - 13:00)
* **Mục tiêu đạt điểm 1.4 (20 điểm):** Bảng so sánh định lượng và luận cứ khoa học giải thích tại sao chọn Stack công nghệ này (Flutter, BLoC, SQLite, Supabase, Dio, SecureStorage).

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.4 LUẬN CỨ KHOA HỌC LỰA CHỌN STACK CÔNG NGHỆ (TECH JUSTIFICATION)**
* **Bảng ma trận so sánh giải pháp:**

| Thành phần | Lựa chọn của Naomi | Giải pháp thay thế | Luận cứ khoa học & Ưu thế vượt trội |
| :--- | :--- | :--- | :--- |
| **Framework** | **Flutter (Dart 3.x)** | React Native, Native | Vẽ trực tiếp qua Skia/Impeller không qua JS Bridge; mượt **60 FPS** khi cuộn 40 ảnh lớn; thỏa mãn Gate Condition build native trên Windows. |
| **State Pattern** | **BLoC Pattern** | Provider, GetX | Phân tách 100% logic khỏi UI; luồng 1 chiều dễ dự đoán; hỗ trợ viết Unit Test trực tiếp bằng `bloc_test`. |
| **Local Database** | **SQLite (`sqflite`)** | Hive, SharedPreferences | Chuẩn quan hệ **3NF**, hỗ trợ ràng buộc Khóa ngoại & Khóa phức hợp; chế độ **WAL Mode** cho tốc độ đọc/ghi $\le 10\text{ ms}$. |
| **Cloud Backend** | **Supabase** | Firebase, Tự dựng | Chuẩn bảo mật SOC2 Type II; hệ quản trị PostgreSQL mở không bị Vendor Lock-in như Firebase NoSQL. |
| **Dual Audio** | **`just_audio` + Spotify** | `audioplayers` đơn thuần | Độc quyền chuyển đổi giữa Lo-Fi offline (0% data) và kho nhạc số 1 thế giới Spotify; quản lý Audio Focus chuẩn OS. |
| **Bảo mật** | **`flutter_secure_storage`**| `shared_preferences` | Mã hóa **AES-256 GCM** gắn với chip phần cứng **Android Keystore / iOS Keychain**; chống trích xuất token khi máy bị root. |

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Thưa thầy, toàn bộ các công nghệ được lựa chọn cho dự án đều có luận cứ khoa học rõ ràng chứ không chọn theo cảm tính:  
> Nhóm chọn **Flutter** thay vì React Native vì Flutter vẽ đồ họa trực tiếp qua engine Impeller mà không phải đi qua cầu nối JavaScript Bridge, đảm bảo cuộn mượt mà 60 FPS mà không bị giật lag.  
> Nhóm chọn **BLoC** thay vì GetX để đảm bảo tính dự đoán và khả năng kiểm thử của Clean Architecture.  
> Nhóm chọn **SQLite** thay vì các NoSQL Key-Value như Hive bởi cấu trúc truyện - chương - trang có tính liên kết quan hệ chặt chẽ và cần ràng buộc khóa ngoại.  
> Cuối cùng, việc kết hợp **`just_audio` và Spotify** mang lại giá trị độc bản cho đề tài giải trí đa giác quan."*

---

## SLIDE 14: [MỤC 1.5] MÔ HÌNH DỮ LIỆU CHUẨN HÓA 3NF & SƠ ĐỒ ERD
* **Thời lượng:** 45 giây (13:00 - 13:45)
* **Mục tiêu đạt điểm 1.5 (10 điểm):** Sơ đồ ERD chuẩn hóa Dạng chuẩn 3 (3NF), giải thích khóa chính phức hợp và chiến lược chỉ mục B-Tree tối ưu hiệu năng.

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.5 MÔ HÌNH DỮ LIỆU QUAN HỆ CHUẨN HÓA (LOGICAL ERD & 3NF)**
* **Sơ đồ ERD 6 Bảng quan hệ chuẩn hóa:**
  1. `comics`: Lưu thông tin metadata tác phẩm (`id` PK, `title`, `author`, `cover_url`...).
  2. `chapters`: Lưu danh mục chương (`id` PK, `comic_id` FK, `chapter_number`...).
  3. `pages`: **Thực thể yếu (Weak Entity)** với Khóa chính phức hợp (`chapter_id` PK/FK, `page_number` PK).
  4. `reading_history`: Lưu tiến trình đọc (`id` PK, `user_id`, `comic_id` FK, `last_page_read`...).
  5. `bookmarks`: Lưu tủ sách yêu thích (`id` PK, `user_id`, `comic_id` FK, `created_at`...).
  6. `offline_downloads`: Quản lý chương tải ngoại tuyến (`id` PK, `chapter_id` FK, `local_path`...).
* **Khung Tối ưu hóa Hiệu năng Cơ sở dữ liệu:**
  - **Chuẩn hóa 3NF:** Loại bỏ hoàn toàn dư thừa dữ liệu và phụ thuộc bắc cầu.
  - **Chế độ WAL (Write-Ahead Logging):** Cho phép vừa đọc vừa ghi đồng thời mà không bị lock DB.
  - **4 Chỉ mục B-Tree chuyên biệt:** `idx_chapters_comic`, `idx_pages_chapter`, `idx_history_user`, `idx_bookmarks_user` giúp tốc độ tìm kiếm đạt độ phức tạp $O(\log N)$ với độ trễ $< 10\text{ ms}$.

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Bước sang Mục 1.5 về Thiết kế Dữ liệu, cơ sở dữ liệu nội bộ `naomi.db` được thiết kế tuân thủ nghiêm ngặt **Dạng chuẩn 3 (Third Normal Form - 3NF)**:  
> Hệ thống gồm 6 bảng quan hệ. Trong đó, bảng `pages` được thiết kế như một thực thể yếu sử dụng Khóa chính phức hợp gồm `chapter_id` và `page_number` để đảm bảo tính toàn vẹn dữ liệu.  
>  
> Để đạt tiêu chuẩn hiệu năng cao theo NFR-04, nhóm kích hoạt cơ chế ghi nhật ký trước **WAL Mode** kết hợp xây dựng **4 chỉ mục B-Tree** tại các cột khóa ngoại thường xuyên tra cứu. Nhờ đó, thao tác ghi vết đọc từng trang của độc giả hoàn tất trong chưa đầy 10 mili-giây, hoàn toàn không gây bất kỳ độ trễ nào trên giao diện người dùng."*

---

## SLIDE 15: [MỤC 1.5] CHIẾN LƯỢC LƯU TRỮ CỤC BỘ ĐA TẦNG & HỢP ĐỒNG API
* **Thời lượng:** 45 giây (13:45 - 14:30)
* **Mục tiêu đạt điểm 1.5 (10 điểm):** Kiến trúc lưu trữ 4 tầng (In-Memory, File, SQLite, Keystore), chính sách dọn dẹp Cache LRU và Hợp đồng API chi tiết.

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.5 CHIẾN LƯỢC LƯU TRỮ CỤC BỘ ĐA TẦNG & HỢP ĐỒNG API**
* **Bố cục 2 phần:**
  - **Phần trái — Kiến trúc Lưu trữ 4 Tầng & Chính sách Thu hồi Cache:**
    - `Tầng 1 (L1 - In-Memory)`: ImageCache của Flutter (giới hạn 100MB RAM, giải phóng ngay ảnh không nhìn thấy).
    - `Tầng 2 (L2 - File System)`: Thư mục chứa ảnh chapter tải về theo cấu trúc `downloads/{comic_id}/{chapter_id}/page_X.jpg`. Giới hạn 30 chapter, chính sách **LRU (Least Recently Used)** tự động gợi ý xóa khi bộ nhớ máy gần đầy.
    - `Tầng 3 (L3 - SQLite)`: Metadata và lịch sử đọc dở (bền vững vĩnh viễn).
    - `Tầng 4 (L4 - Secure Keystore)`: JWT Token mã hóa phần cứng.
  - **Phần phải — Danh mục Hợp đồng API (12 Endpoints chuẩn RESTful):**
    - `MangaDex v5 API (5 Endpoints)`: Trending (`/manga`), Search, Detail, Feed (`/manga/{id}/feed`), CDN Server (`/at-home/server/{id}`).
    - `Supabase Auth API (3 Endpoints)`: Sign Up, Sign In with Password, Sign Out.
    - `Spotify Web API (4 Endpoints)`: User Profile (`/v1/me`), Search, Curated Playlists, Player Control (`/v1/me/player/play`).
    - Xử lý mã lỗi chuẩn hóa: `401 Unauthorized`, `404 Not Found`, `429 Rate Limit` (tự động Exponential Backoff retry).

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Để hiện thực hóa triết lý Offline-First mà không làm đầy bộ nhớ máy của người dùng, nhóm triển khai **Mô hình Lưu trữ Cục bộ 4 tầng**:  
> Từ tầng L1 trên RAM, L2 trên File System, L3 trên SQLite đến L4 trên Keystore bảo mật. Nhóm thiết lập chính sách dọn dẹp bộ nhớ theo thuật toán **LRU (Least Recently Used)** và cung cấp giao diện trực quan cho phép độc giả tự quản lý dung lượng và xóa cache 1-chạm.  
>  
> Về mặt giao tiếp đám mây, toàn bộ 12 Endpoint của MangaDex, Supabase và Spotify đều được đặc tả đầy đủ Request, Response mẫu và mã lỗi HTTP. Riêng đối với lỗi nghẽn mạng hoặc quá tải HTTP 429, tầng mạng Dio Client được cài đặt thuật toán **Exponential Backoff** để tự động thử lại sau các khoảng thời gian lũy thừa, đảm bảo ứng dụng không bao giờ bị văng khi mạng chập chờn."*

---

## SLIDE 16: [MỤC 1.6] HỆ THỐNG THIẾT KẾ UI/UX, DESIGN TOKENS & 4 TRẠNG THÁI MÀN HÌNH
* **Thời lượng:** 45 giây (14:30 - 15:15)
* **Mục tiêu đạt điểm 1.6 (15 điểm):** Trình diễn Hệ thống Design Tokens (Muted Minimal, Dark AMOLED, WCAG 2.1 AA), typography scale và đặc tả đầy đủ 4 trạng thái màn hình (Normal, Loading, Empty, Error).

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.6 HỆ THỐNG THIẾT KẾ UI/UX & ĐẶC TẢ 4 TRẠNG THÁI MÀN HÌNH**
* **Bố cục 2 phần trực quan:**
  - **Phần trên — Design System & Bảng màu Design Tokens chuẩn WCAG 2.1 AA:**
    - 🎨 Palette màu chuẩn hóa trong code (`AppColors`): Primary Tím oải hương (`#7066A6`), Dark AMOLED (`#111116`), Surface (`#1A1A22`), Spotify Green (`#1DB954`).
    - 👁️ **Độ tương phản chữ đạt chuẩn WCAG 2.1 AA:** Văn bản chính trên nền đen đạt tỷ lệ tương phản vượt trội **$13.8:1$** (vượt xa chuẩn tối thiểu 4.5:1).
    - 🔤 Chuẩn hóa Typography Material 3 Type Scale và **100% UI tương tác bằng tiếng Anh**.
  - **Phần dưới — Lưới 4 Trạng thái bắt buộc của màn hình (Mẫu minh họa trên Discover / Library Screen):**
    1. 🟢 **Trạng thái Bình thường (Normal/Success State):** Lưới bìa truyện, thẻ Continue Reading nổi bật, mini-player đĩa than đang xoay.
    2. 🟡 **Trạng thái Đang tải (Loading State):** Hiệu ứng khung xương lấp lánh (Shimmer / Skeleton), tuyệt đối không dùng vòng quay tròn đơn điệu.
    3. ⚪ **Trạng thái Trống (Empty State):** Minh họa nghệ thuật kèm thông điệp rõ ràng và nút bấm kêu gọi hành động (VD: "Your library is empty — Explore Trending").
    4. 🔴 **Trạng thái Lỗi (Error State):** Báo lỗi mất mạng thân thiện kèm nút bấm "Retry Again" để khôi phục nhanh.

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Chuyển sang Mục 1.6 về Thiết kế UI/UX, giao diện của Naomi được thiết kế theo triết lý **Muted Minimal & Reader-First** tuân thủ Google Material 3 và Apple HIG:  
> Toàn bộ bảng màu được quản lý tập trung qua Design Tokens. Tông màu nền chủ đạo là AMOLED Pure Black giúp bảo vệ mắt bạn Kiệt khi đọc đêm muộn, với độ tương phản văn bản đạt **13.8:1**, vượt xa tiêu chuẩn trợ năng quốc tế WCAG 2.1 AA.  
>  
> Đáp ứng yêu cầu khắt khe của Rubric mục 1.6, tất cả các màn hình chính trong Naomi đều được đặc tả hoàn chỉnh qua **4 trạng thái giao diện**:  
> Trạng thái bình thường;  
> Trạng thái tải trang bằng hiệu ứng khung xương Shimmer hiện đại;  
> Trạng thái trống có hình minh họa và nút điều hướng khám phá;  
> Và trạng thái lỗi mạng có nút Thử lại tức thì, đảm bảo trải nghiệm người dùng không bao giờ rơi vào ngõ cụt."*

---

## SLIDE 17: [MỤC 1.6 & TỔNG KẾT] TRÌNH DIỄN LUỒNG NGƯỜI DÙNG & CLICKABLE PROTOTYPE
* **Thời lượng:** 30 giây (15:15 - 15:45)
* **Mục tiêu đạt điểm 1.6 (15 điểm) & Khép lại bài thuyết trình xuất sắc:** Trình diễn 7 màn hình then chốt, cung cấp link Clickable Prototype trên Figma và khẳng định tính sẵn sàng 100% cho Assignment 02.

### 1. Bố cục & Thiết kế Slide (Visual Layout):
* **Tiêu đề:** **1.6 NỀN TẢNG THIẾT KẾ HOÀN CHỈNH & SẴN SÀNG CHO HIỆN THỰC HÓA**
* **Trình bày trực quan dàn mockup 7 màn hình then chốt (Hi-Fi Screens mockup):**
  1. `LoginScreen` (Supabase Auth + Chế độ Khách Guest Reader).
  2. `DiscoverScreen` (Banner thịnh hành, Tiếp tục đọc, Danh mục thể loại).
  3. `ComicDetailScreen` (Thông tin tác giả, Tóm tắt, Danh sách chapter, Nút Bookmark).
  4. `ReaderScreen` (Trình đọc 2 chế độ: Cuộn dọc Webtoon 60 FPS & Lật trang Manga, thanh điều hướng ẩn thông minh).
  5. `AmbientAudioSheet & FloatingMiniPlayer` (Điều khiển nhạc Lo-Fi offline và danh sách phát trực tuyến Spotify).
  6. `LibraryScreen` (3 Tab: History, Bookmarks, Offline Downloads).
  7. `ProfileScreen` (Quản lý dung lượng Cache, Chuyển Theme Dark/Light).
* **Khung QR Code & Đường dẫn Clickable Prototype trên Figma:**
  - Link Figma: `figma.com/design/jCmoi6OPmZAAfM88KSRgBy/Naomi-...`
* **Thông điệp kết luận:** *"Bản đặc tả từ 1.1 đến 1.6 đã hoàn thiện 100% tính nhất quán (Traceability), sẵn sàng làm baseline nghiệm thu xuất sắc cho giai đoạn code A02."*

### 2. Kịch bản thuyết trình (Speaker Script):
> *"Để khép lại bài báo cáo, trên màn hình là tổng thể **7 màn hình then chốt** với đầy đủ các luồng tương tác của ứng dụng Naomi đã được nhóm thiết kế hoàn chỉnh trên Figma. Thầy và các bạn có thể quét mã QR trên slide để trải nghiệm bản **Clickable Prototype** tương tác trực tiếp.  
>  
> Tóm lại, từ việc thấu hiểu nỗi đau của người dùng ở Mục 1.1, phân loại chức năng MoSCoW ở 1.2, định lượng chỉ số kỹ thuật ở 1.3, thiết lập Clean Architecture ở 1.4, chuẩn hóa dữ liệu 3NF ở 1.5 cho đến hệ thống UI/UX hoàn chỉnh ở 1.6 — nhóm đã tạo nên một bộ đặc tả đồng nhất, chặt chẽ và khả thi 100%. Đây sẽ là kim chỉ nam vững chắc để chúng em tự tin hoàn thành xuất sắc sản phẩm chạy thực tế ở Assignment 02.  
>  
> Nhóm em xin chân thành cảm ơn thầy đã chú ý lắng nghe và rất mong nhận được những góp ý quý báu từ thầy ạ!"*

---

# BỘ CÂU HỎI VẤN ĐÁP DỰ PHÒNG & HƯỚNG DẪN TRẢ LỜI "ĂN ĐIỂM" VỚI HỘI ĐỒNG

Dưới đây là 5 câu hỏi trọng tâm mà giảng viên thường chất vấn nhiều nhất trong buổi bảo vệ Specification và cách trả lời chuẩn kỹ thuật giúp nhóm ghi điểm tuyệt đối:

### ❓ Câu 1 (Hỏi về 1.1 & 1.3): "Tại sao khảo sát chỉ có 4 người? Liệu mẫu này có đủ tính đại diện khoa học không?"
* **Cách trả lời ăn điểm:**  
  *"Thưa thầy, theo giáo trình Kỹ nghệ Yêu cầu của Ian Sommerville (Chương 4), ở giai đoạn khởi tạo (Inception phase), phương pháp **Phỏng vấn bán cấu trúc chuyên sâu (Semi-structured In-depth Interview)** trên một nhóm mẫu nhỏ tập trung ($N = 4$ đến $6$) mang lại giá trị định tính sâu sắc hơn rất nhiều so với phát phiếu khảo sát đại trà hời hợt. Nhóm đã chọn 4 đối tượng đại diện chuẩn xác cho 3 nhóm độc giả cốt lõi: sinh viên kỹ thuật, sinh viên kinh tế và người đi làm. Nhờ phỏng vấn sâu, nhóm mới phát hiện ra insight cực kỳ đắt giá là 100% người đọc đều có thói quen nghe nhạc khi đọc truyện và nỗi đau giật lag khi cuộn 40 trang ảnh — từ đó giúp định hình nên Dual Audio Engine và kiến trúc tối ưu 60 FPS của Naomi."*

### ❓ Câu 2 (Hỏi về 1.4): "Tại sao lại chọn BLoC mà không dùng Provider hay GetX cho nhanh?"
* **Cách trả lời ăn điểm:**  
  *"Dạ thưa thầy, GetX phát triển rất nhanh nhưng vi phạm nguyên tắc Clean Architecture vì trộn lẫn logic vào UI và cơ chế cập nhật trạng thái của GetX rất khó kiểm soát trong các danh sách cuộn ảnh dài, dễ gây rò rỉ bộ nhớ. Còn BLoC hoạt động theo luồng dữ liệu một chiều khép kín: Event vào $\rightarrow$ Xử lý nghiệp vụ $\rightarrow$ Bắn ra State. Điều này giúp code có tính dự đoán cực cao, tách rời 100% tầng UI và đặc biệt là cực kỳ dễ viết Unit Test cho từng State bằng thư viện `bloc_test`, đáp ứng trọn vẹn tiêu chí kiểm thử cho Assignment 02 ạ."*

### ❓ Câu 3 (Hỏi về 1.3 & 1.4): "Làm sao nhóm đảm bảo cuộn 40-60 ảnh Webtoon mà đạt được 55-60 FPS không bị Out-Of-Memory?"
* **Cách trả lời ăn điểm:**  
  *"Thưa thầy, nhóm giải quyết bài toán này bằng giải pháp 3 lớp:  
  Thứ nhất, sử dụng danh sách ảo hóa `ListView.builder` kết hợp cấu hình `cacheExtent: 2500` để nạp trước ảnh vào bộ nhớ đồ họa một cách mượt mà.  
  Thứ hai, nhóm can thiệp vào `PaintingBinding.instance.imageCache` để giới hạn trần bộ nhớ đệm RAM tối đa 100MB và tự động gọi `clearLiveImages()` thu hồi ngay các trang ảnh đã cuộn khuất màn hình.  
  Thứ ba, Flutter sử dụng engine đồ họa Impeller biên dịch trực tiếp ra mã máy native, loại bỏ hoàn toàn hiện tượng nghẽn cổ chai của JavaScript Bridge ạ."*

### ❓ Câu 4 (Hỏi về 1.5): "Tại sao lại dùng SQLite mà không dùng Hive hoặc SharedPreferences cho nhẹ?"
* **Cách trả lời ăn điểm:**  
  *"Dạ thưa thầy, dữ liệu của app đọc truyện có mối quan hệ phụ thuộc phân cấp rất chặt chẽ: Một Comic có nhiều Chapter, một Chapter có nhiều Page, và một Page có vị trí đọc dở liên kết với User. Nếu dùng NoSQL Key-Value như SharedPreferences hay Hive thì khi cần truy vấn phức tạp hoặc xóa một bộ truyện kéo theo xóa cascade toàn bộ chapter và file ảnh sẽ rất dễ gây bất nhất dữ liệu. SQLite hỗ trợ chuẩn hóa 3NF, ràng buộc Khóa ngoại (Foreign Keys) và Khóa phức hợp, đồng thời khi bật WAL Mode thì tốc độ đọc ghi đạt dưới 10ms, hoàn toàn đáp ứng xuất sắc yêu cầu di động ạ."*

### ❓ Câu 5 (Hỏi về 1.4 & 1.6): "Ứng dụng tích hợp Spotify như thế nào? Có vi phạm bản quyền hay gây giật app không?"
* **Cách trả lời ăn điểm:**  
  *"Thưa thầy, Naomi tích hợp Spotify thông qua **Spotify Developer Web API** và giao thức **Spotify Connect** chính thức của hãng. Ứng dụng chỉ đóng vai trò là một Client điều khiển và phát luồng âm thanh thông qua token xác thực an toàn được lưu trong Keystore.  
  Hơn nữa, dịch vụ `AmbientAudioService` hoạt động hoàn toàn bất đồng bộ và được quản lý vòng đời bởi `audio_session`, nên việc phát nhạc chạy trên luồng nền độc lập, hoàn toàn không chiếm dụng luồng giao diện chính (UI Thread) nên không thể gây giật lag khi cuộn đọc truyện ạ."*
