program MainProgram;

//recommended window size: 100x50
//author: Lam Chun Wai 6B (29)
//last update: 10/1/2016

uses
   crt, sysutils, picker;
const
   ADMIN_USERNAME = 'admin_01';      //change username and password here
   ADMIN_PW = 'admin_PW';
   MAX_USER = 1000;
   MAX_PGME = 1000;
   MAX_CALENDAR_ITEM = 50;
   MAX_SUBJECT = 7;
   MAX_MENU_NO = 10;
   MAX_Y_WINDOW_SIZE = 50;
   TITLE_X = 35;
   TITLE_Y = 1;
   DELETE_MARK = '*#*#(DELETE)#*#*'; //mark delete item with this string, cannot be longer than 30
   DEFAULT_COLOUR = 6;  //brown
type
   //TSubjectType = (NA, Phy, Chem, Bio, VA, Geog, BA, Econ, CHist, Hist, Music, CLit, ICT);
   TGradeType = 0..7;              //elective grade, 0 = nil subject
   TUserType = record
                  Username, UserPW: string;
                  Name: string[30];
                  Sex: char;
                  Chi, Eng, Maths, LS: TGradeType;
                  x1, x2, x3: TSubjectType;
                  x1gr, x2gr ,x3gr: TGradeType;
                  clSetting: 2..17;
               end;
   TPgmeType = record
                  u_name: string[10];
                  cat_no: string[6];
                  fund: string[15];
                  pgme: string[30];
                  pgme_full: string[100];
                  median: -1..60;          //-1 = not available
                  method: string;
               end;
   TCldarType = record
                   keydate_temp: string[10];
                   keydate: TDateTime;
                   content: ansistring;    //no limit to 255 char
                end;
   TPgmeArray    = array[1..MAX_PGME] of TPgmeType;                     //cannot use dynamic array in this compiler
   TCldarArray   = array[1..MAX_CALENDAR_ITEM] of TCldarType;
   TMenuArray    = array[1..MAX_MENU_NO] of string[20];
   TUserArray    = array[1..MAX_USER] of TUserType;
   TSubjectArray = array[1..MAX_SUBJECT] of integer;                    //for calculator
var
   admin                                              : boolean;        //user is admin or not
   login_choice, mcount, menu_item, user_id, colour   : integer;
   numDb, numUgc, numSelfFin, numSssdp, numCal        : integer;
   userDb, ugcDb, selfFinDb, sssdpDb, mfile, cal_file : text;

   user                : TUserArray;
   ugc, selfFin, sssdp : TPgmeArray;
   cldar               : TCldarArray;
   mitem               : TMenuArray;

procedure welcomeScreen; forward;
procedure mainMenu(flag: integer); forward;
procedure userReg(var user_count: integer); forward;
procedure pgmeListItem(const inArray: TPgmeArray; const index: integer;full: integer); forward;

procedure blackScr;
begin
   textBackground(Black);
   window(20, 2, 100, 50);
   clrscr;
end;

procedure topBar(title: string);
begin
   textBackground(colour);
   window(20, 1, 100, 2);
   clrscr;
   gotoxy(39 - (length(title) div 2), TITLE_Y);
   write(title);
end;

procedure wordInput(var S: string; word, echo: char);     //procedure that allows program to fetch string when keypressed
begin
   case word of
      #128..#255: ;                       //Extended ASCII characters
      #73 : ;
      #81 : ;
      #08 : if length(S) > 0 then         //BackSpace
               begin
                  dec(S[0]); write(#08#32#08);   //deprecate write(#08)--contains bug when typing
               end;
      #32 : if echo = '*' then            //space bar
            begin
               S := S + ' ';              //if input password show '*'
               write(echo);
            end
            else S := S + ' ';
      #00 : word := readkey;              //flush scancode
      #33..#72,
      #74..#80,
      #82..#127 : begin
                    S := S + word; write(echo);
                 end;
   else
   //invalid characters
   end;
end;

function toString(const subject: TSubjectType): string[20];
begin
   case subject of
         NA   : toString := '---';
         Phy  : toString := 'Physics';
         Chem : toString := 'Chemistry';
         Bio  : toString := 'Biology';
         VA   : toString := 'Visual Art';
         Geog : toString := 'Geography';
         BA   : toString := 'BAFS';
         Econ : toString := 'Economics';
         CHist: toString := 'Chinese History';
         Hist : toString := 'History';
         Music: toString := 'Music';
         CLit : toString := 'Chinese Literature';
         ICT  : toString := 'ICT';
   end;
end;

function toStringColour(const cl: integer): string[20];
begin
   case cl of
      1:  toStringColour := 'Blue';
      2:  toStringColour := 'Green';
      3:  toStringColour := 'Cyan';
      4:  toStringColour := 'Red';
      5:  toStringColour := 'Magenta';
      6:  toStringColour := 'Brown';
   end;
end;

function gradeToString(const grade: integer): string[3];
begin
    case grade of
       0: gradeToString := '---';
       1..5: str(grade, gradeToString);
       6: gradeToString := '5*';
       7: gradeToString := '5**';
    end;
end;

procedure saveUser(count: integer);
var
   i: integer;
begin
   rewrite(userDb);
   for i := 1 to count do
      with user[i] do
         if Username <> DELETE_MARK             //if not marked as delete
            then begin
                    writeln(userDb, Username);
                    writeln(userDb, UserPW);
                    writeln(userDb, Name);
                    writeln(userDb, Sex);
                    writeln(userDb, Chi, ' ', Eng, ' ',Maths, ' ',LS);
                    writeln(userDb, ord(x1), ' ',ord(x2), ' ',ord(x3));
                    writeln(userDb, x1gr, ' ',x2gr, ' ',x3gr);
                    writeln(userDb, clSetting);
                    writeln(userDb);
                 end;
   close(userDb);
end;

procedure savePgme;         //save all programme
var
   i: integer;
begin
   rewrite(ugcDb);
   for i := 1 to numUgc do
      with ugc[i] do
         if pgme <> DELETE_MARK             //if not marked as delete
            then begin
                    writeln(ugcDb, u_name);
                    writeln(ugcDb, cat_no);
                    writeln(ugcDb, fund);
                    writeln(ugcDb, pgme);
                    writeln(ugcDb, pgme_full);
                    writeln(ugcDb, median);
                    writeln(ugcDb, method);
                    writeln(ugcDb);
                 end;
   close(ugcDb);
   rewrite(selfFinDb);
   for i := 1 to numselfFin do
      with selfFin[i] do
         if pgme <> DELETE_MARK
            then begin
                    writeln(selfFinDb, u_name);
                    writeln(selfFinDb, cat_no);
                    writeln(selfFinDb, fund);
                    writeln(selfFinDb, pgme);
                    writeln(selfFinDb, pgme_full);
                    writeln(selfFinDb, median);
                    writeln(selfFinDb, method);
                    writeln(selfFinDb);
                 end;
   close(selfFinDb);
   rewrite(sssdpDb);
   for i := 1 to numSssdp do
      with sssdp[i] do
         if pgme <> DELETE_MARK
            then begin
                    writeln(sssdpDb, u_name);
                    writeln(sssdpDb, cat_no);
                    writeln(sssdpDb, fund);
                    writeln(sssdpDb, pgme);
                    writeln(sssdpDb, pgme_full);
                    writeln(sssdpDb, median);
                    writeln(sssdpDb, method);
                    writeln(sssdpDb);
                 end;
   close(sssdpDb);
end;

procedure slideUpAnim(const x, y_start, y_end, interval: integer; const str: string);
var i: integer;
begin
   cursoroff;
   for i := y_start downto y_end do begin
       window(x, i + 1, length(str) + x, i + 2);     //cover text below
       clrscr;
       textbackground(black);
       write(str);
       delay(interval);
   end;
end;

procedure qSortSubject(var arr: TSubjectArray; left, right: integer);
var
   i, j: integer;
   pivot : -1..60;
   tmp: integer;
begin
   i := left;
   j := right;
   pivot := arr[(left + right) div 2];       //actually pivot can be any element in an array
   repeat
      while pivot > arr[i] do inc(i);
      while pivot < arr[j] do dec(j);
         if i <= j then                      //swap
         begin
            tmp := arr[i];
            arr[i] := arr[j];
            arr[j] := tmp;
            dec(j);
            inc(i);
         end
   until i > j;
   if left < j then qSortSubject(arr, left, j);
   if i < right then qSortSubject(arr, i, right);
end;

procedure qSortPgmeCat(var arr: TPgmeArray; left, right: integer);
var
   i, j: integer;
   pivot : string;
   tmp: TPgmeType;
begin
   i := left;
   j := right;
   pivot := arr[(left + right) div 2].cat_no;
   repeat
      while pivot > arr[i].cat_no do inc(i);
      while pivot < arr[j].cat_no do dec(j);
         if i <= j then
         begin
            tmp := arr[i];
            arr[i] := arr[j];
            arr[j] := tmp;
            dec(j);
            inc(i);
         end
   until i > j;
   if left < j then qSortPgmeCat(arr, left, j);
   if i < right then qSortPgmeCat(arr, i, right);
end;

function binSearchPgmeCat(var arr: TPgmeArray; key: string; l, h: integer): integer; //return the position of the target in array
var
   mid: integer;
begin
   qSortPgmeCat(arr, l, h);  //ensure the array is sorted
   key := 'JS' + key;
   binSearchPgmeCat := -1;   //assume not found (a flag)
   while (l <= h) do
   begin
      mid := (l + h) div 2;
      if arr[mid].cat_no > key then h := mid - 1
      else if arr[mid].cat_no < key then l := mid + 1
           else
           begin
              binSearchPgmeCat := mid;
              break;
           end;
   end;
end;

procedure qSortPgmeMedian(var arr: TPgmeArray; left, right: integer);
var
   i, j: integer;
   pivot : -1..60;
   tmp: TPgmeType;
begin
   i := left;
   j := right;
   pivot := arr[(left + right) div 2].median;
   repeat
      while pivot > arr[i].median do inc(i);
      while pivot < arr[j].median do dec(j);
         if i <= j then
         begin
            tmp := arr[i];
            arr[i] := arr[j];
            arr[j] := tmp;
            dec(j);
            inc(i);
         end
   until i > j;
   if left < j then qSortPgmeMedian(arr, left, j);
   if i < right then qSortPgmeMedian(arr, i, right);
end;

function binSearchPgmeMedian(var arr: TPgmeArray; key, l, h: integer): integer; //return the position of the target in array
var
   mid: integer;
begin
   qSortPgmeMedian(arr, l, h);  //ensure the array is sorted
   binSearchPgmeMedian := -1;   //assume not found (a flag)
   while (l <= h) do
   begin
      mid := (l + h) div 2;
      if arr[mid].median > key then h := mid - 1
      else if arr[mid].median < key then l := mid + 1
           else
           begin
              binSearchPgmeMedian := mid;
              break;
           end;
   end;
end;

procedure qSortUser(left, right: integer);
var
   i, j: integer;
   pivot : string;
   tmp: TUserType;
begin
   i := left;
   j := right;
   pivot := user[(left + right) div 2].username;
   repeat
      while pivot > user[i].username do inc(i);
      while pivot < user[j].username do dec(j);
         if i <= j then
         begin
            tmp := user[i];
            user[i] := user[j];
            user[j] := tmp;
            dec(j);
            inc(i);
         end
   until i > j;
   if left < j then qSortUser(left, j);
   if i < right then qSortUser(i, right);
end;

function binSearchUser(key: string): integer;
var
   l, mid, h: integer;
begin
   l := 1;
   h := numDb;
   qSortUser(l, h);       //ensure the array is sorted
   binSearchUser := -1;   //assume not found (a flag)
   while (l <= h) do
   begin
      mid := (l + h) div 2;
      if user[mid].Username > key then h := mid - 1
      else if user[mid].Username < key then l := mid + 1
           else
           begin
              binSearchUser := mid;
              break;
           end;
   end;
end;

procedure home;
var
   key: char;
   i: integer;
   YY, MM, DD, cYY, cMM, cDD: word;
begin
   topBar('HOME');
   blackScr;
   textBackground(Black);
   window(20, 2, 90, 50);
   clrscr;
   gotoxy(2, 4);
   //get current date
   DeCodeDate(Date, cYY, cMM, cDD);
   writeln('[ IMPORTANT DATES ]    Today: ', DateTimeToStr(Date), '(', ShortDayNames[DayOfWeek(Date)], ')');  //DateTimeToStr(Date) & ShortDayNames[DayOfWeek(Date)] or FormatDateTime('DD/MM/YYYY (DDD)', Date) will do the trick
   writeln('===============================================');
   writeln;
   for i := 1 to numCal do
   begin
      with cldar[i] do
      begin
         DeCodeDate(keydate, YY, MM, DD);
         //shows only this month''s item
         if (MM = cMM) then
         begin
            writeln('  ', DateTimeToStr(keydate), '(', ShortDayNames[DayOfWeek(keydate)], ')');
            writeln('    ', content);
            writeln;
         end
      end;
   end;
   repeat
      key := readkey;
      if (key = #0) and (key <> #27)
      then begin
              key := readkey;
              case key of
                 #75: mainMenu(0);
              end;
           end
   until key = #75;
end;

procedure searchPgme(key: string; var result: TPgmeArray; var arr_i: integer);         //linear search: array isnt sorted
var
   i: integer;
begin
   i := 0;
   arr_i := 0;               //return 0 if not found
   key := lowercase(key);    //perform case insensitive search->convert all to lowercase
   while i <= numUgc do
   begin
      inc(i);
      with Ugc[i] do
      begin
         if (pos(key, lowercase(u_name)) <> 0) or
             (pos(key, lowercase(cat_no)) <> 0) or
             (pos(key, lowercase(fund)) <> 0) or
             (pos(key, lowercase(pgme)) <> 0) or
             (pos(key, lowercase(pgme_full)) <> 0) then
             begin
                inc(arr_i);
                result[arr_i] := ugc[i];     //copy record to output
             end;
      end;
   end;
   i := 0;
   while i <= numSssdp do
   begin
      inc(i);
      with sssdp[i] do
      begin
         if (pos(key, lowercase(u_name)) <> 0) or
             (pos(key, lowercase(cat_no)) <> 0) or
             (pos(key, lowercase(fund)) <> 0) or
             (pos(key, lowercase(pgme)) <> 0) or
             (pos(key, lowercase(pgme_full)) <> 0) then
             begin
                inc(arr_i);
                result[arr_i] := sssdp[i];
             end;
      end;
   end;
   i := 0;
   while i <= numSelfFin do
   begin
      inc(i);
      with selfFin[i] do
      begin
         if (pos(key, lowercase(u_name)) <> 0) or
             (pos(key, lowercase(cat_no)) <> 0) or
             (pos(key, lowercase(fund)) <> 0) or
             (pos(key, lowercase(pgme)) <> 0) or
             (pos(key, lowercase(pgme_full)) <> 0) then
             begin
                inc(arr_i);
                result[arr_i] := selfFin[i];
             end;
      end;
   end;
end;

procedure searchBox(cx: integer; output: string);
begin
   textBackground(colour);
   textColor(Black);
   window(cx, 5, 90, 5);
   clrscr;
   write(' ', output);
   textColor(White);
   lowvideo;
end;

procedure searchPgmeListview(pointer, page_count, max: integer; var maxSPage: integer; inArr: TPgmeArray);
const
   MAX_ITEM = 5;
var
   i, end_pointer: integer;
begin
   textBackground(Black);
   window(20, 7, 100, 50);
   clrscr;
   if max mod MAX_ITEM = 0
   then maxSPage := max div MAX_ITEM        //can be equally divided
   else maxSPage := max div MAX_ITEM + 1;   //cannot be equally divided, so add 1 to display last elements in array

   if max = 0 then maxSPage := 1;           //null array -> page indicator = 1

   end_pointer := pointer + MAX_ITEM - 1;
   if end_pointer > max then end_pointer := max;

   for i := pointer to end_pointer do       //show list item
   begin
      pgmeListItem(inArr, i, 1);
   end;
   window(25, 48, 100, 50);
   gotoxy(20, 1);write('USE PgUp/PgDn TO SCROLL');
   gotoxy(30, 2);write('<', page_count, '/', maxSPage, '>');
end;

procedure search;
const
   MAX_ITEM = 5;
var
   close, reset: boolean;           //prevent crash if enter 'K'
   key: char;
   sText: string;            //target to search
   sArr: TPgmeArray;         //array to be displayed
   sCount, sPointer, sPage, sPageMax, i: integer;
begin
   cursoroff;
   topBar('SEARCH');
   blackScr;
   gotoxy(3, 4); writeln('Search: ');
   writeln('================================================================================');
   close := false;
   sText := '';
   sCount := 0;
   sPointer := 1;
   sPage := 1;
   sPageMax := 1;
   searchBox(31, sText);
   for i := 1 to MAX_PGME do      //initialize
   with sArr[i] do
      begin
         u_name := '';
         cat_no := '';
         fund := '';
         pgme := '';
         pgme_full := '';
      end;

   repeat
      reset := true;
      key := readkey;
      if (key = #0) and (key <> #27)
      then begin
              key := readkey;
              case key of
                 #75: begin
                         close := true;
                         mainMenu(0);
                      end;
                 #73: begin  //pgup
                         sPointer := sPointer - MAX_ITEM;
                         sPage := sPage - 1;
                         reset := false;
                      end;
                 #81: begin  //pgdn
                         if sPointer + MAX_ITEM < sCount
                         then sPointer := sPointer + MAX_ITEM;
                         sPage := sPage + 1;
                         reset := false;
                      end;
               else
               end;
           end;
      if (sPointer <= 0) or (sPage <= 0) then
      begin
         sPointer := 1;
         sPage := 1;
      end;
      if sPage > sPageMax then sPage := sPageMax;
      if reset then  //prevent search when not typing
      begin
         sPage := 1; //reset page
         sPageMax := 1;
         sPointer := 1;
         wordInput(sText, key, key);
         searchBox(31, sText);
         searchPgme(sText, sArr, sCount);
      end;
      textBackground(Black);
      window(20, 7, 100, 50);
      clrscr;
      if sCount <> 0 then
      begin
         searchPgmeListview(sPointer, sPage, sCount, sPageMax, sArr);
      end
      else begin
              window(20, 7, 100, 50);
              clrscr;
              writeln;
              write('        NO RESULT');
           end;
   until close;
end;

procedure userEdit(user_pointer: integer);
var
   ch: char;
   pw: string;
begin
   cursoron;
   window(1, 1, 100, 50);
   textBackground(Black);
   clrscr;
   textBackground(colour);
   gotoxy(35, 5);
   write('         EDIT PROFILE        ');       //title
   textBackground(Black);
   textColor(White);
   lowvideo;
   window(30, 10, 100, 50);
   with user[user_pointer] do
   begin
      write('Password( >4 chararcters ): '); pw := '';
      repeat
         ch := readkey;
         wordInput(pw, ch, '*');
      until (ch = #13);
      while length(pw) <= 4 do                                //password check
      begin
         if length(pw) = 0 then
         begin
            window(30, 13, 100, 15);
            write('This is a mandatory field. Cannot be null.');
            delay(2000);
            clrscr;
         end

         else
         begin
            window(30, 13, 100, 15);
            write('Password should contain >4 characters.');
            delay(2000);
            clrscr;
         end;
         window(30, 12, 100, 50);
         clrscr;
         write('Password( >4 chararcters ): '); pw := '';
         repeat
            ch := readkey;
            wordInput(pw, ch, '*');
         until (ch = #13);
      end;
      UserPW := pw;

      writeln;
      writeln;
      write('Name: '); readln(name);
      writeln;
      write('Sex(M/F): ');
      Sex := sexPicker(40, 14, colour);            //invoke picker
      writeln(Sex);
      window(30, 16, 100, 50);
      clrscr;
      write('Expected Chinese result: ');
      Chi := gradePicker(55, 16, 1, 7, colour);
      write(gradeToString(Chi));
      window(30, 18, 100, 50);
      clrscr;
      write('Expected English result: ');
      Eng := gradePicker(55, 18, 1, 7, colour);
      write(gradeToString(Eng));
      window(30, 20, 100, 50);
      clrscr;
      write('Expected Maths result: ');
      Maths := gradePicker(55, 20, 1, 7, colour);
      write(gradeToString(Maths));
      window(30, 22, 100, 50);
      clrscr;
      write('Expected LS result: ');
      LS := gradePicker(55, 22, 1, 7, colour);
      write(gradeToString(LS));
      window(30, 24, 100, 50);
      clrscr;
      write('Elective 1: ');
      x1 := electivePicker(42, 24, colour);
      write(toString(x1));
      window(30, 26, 100, 50);
      clrscr;
      write('Elective 2: ');
      x2 := electivePicker(42, 26, colour);
      write(toString(x2));
      window(30, 28, 100, 50);
      clrscr;
      write('Elective 3: ');
      x3 := electivePicker(42, 28, colour);
      write(toString(x3));
      window(30, 30, 100, 50);
      clrscr;
      write('Expected Elective 1 result: ');
      x1gr := gradePicker(60, 30, 0, 7, colour);
      write(gradeToString(x1gr));
      window(30, 32, 100, 50);
      clrscr;
      write('Expected Elective 2 result: ');
      x2gr := gradePicker(60, 32, 0, 7, colour);
      write(gradeToString(x2gr));
      window(30, 34, 100, 50);
      clrscr;
      write('Expected Elective 3 result: ');
      x3gr := gradePicker(60, 34, 0, 7, colour);
      write(gradeToString(x3gr));
      window(30, 38, 100, 50);
      highvideo;
      writeln('Press ENTER to confirm edit.');
      readln;

      saveUser(numDb);
   end;
   write('EDIT SUCCESSFUL');
   delay(1000);
   lowvideo;
   menu_item := 3;
   mainMenu(1);
end;

procedure userProfileView(pointer: integer);
const
   ALIGN = 60;
begin
   with user[pointer] do begin
      writeln(' Username: ', Username:ALIGN - length(' Username: ') + length(username));
      writeln;
      writeln(' Password: ', UserPW:ALIGN - length(' Password: ') + length(UserPW));
      writeln;
      writeln(' Name: ', Name:ALIGN - length(' Name: ') + length(Name));
      writeln;
      writeln(' Sex: ', Sex:ALIGN - length(' Sex: ') + 1);
      writeln;
      writeln(' Expected Chinese Result: ', gradeToString(Chi):ALIGN - length(' Expected Chinese Result: ') + length(gradeToString(Chi)));
      writeln;
      writeln(' Expected English Result: ', gradeToString(Eng):ALIGN - length(' Expected English Result: ') + length(gradeToString(Eng)));
      writeln;
      writeln(' Expected Maths Result: ', gradeToString(Maths):ALIGN - length(' Expected Maths Result: ') + length(gradeToString(Maths)));
      writeln;
      writeln(' Expected LS Result: ', gradeToString(LS):ALIGN - length(' Expected LS Result: ') + length(gradeToString(LS)));
      writeln;
      writeln(' Elective 1: ', toString(x1):ALIGN - length(' Elective 1: ') + length(toString(x1)));
      writeln;
      writeln(' Elective 2: ', toString(x2):ALIGN - length(' Elective 2: ') + length(toString(x2)));
      writeln;
      writeln(' Elective 3: ', toString(x3):ALIGN - length(' Elective 3: ') + length(toString(x3)));
      writeln;
      writeln(' Expected ', toString(x1), ' Result: ', gradeToString(x1gr):ALIGN - length(concat(' Expected ', toString(x1), ' Result: ')) + length(gradeToString(x1gr)));
      writeln;
      writeln(' Expected ', toString(x2), ' Result: ', gradeToString(x2gr):ALIGN - length(concat(' Expected ', toString(x2), ' Result: ')) + length(gradeToString(x2gr)));
      writeln;
      writeln(' Expected ', toString(x3), ' Result: ', gradeToString(x3gr):ALIGN - length(concat(' Expected ', toString(x3), ' Result: ')) + length(gradeToString(x3gr)));
      writeln;
      write(' Accent Color: ');
      textBackground(user[pointer].clSetting);
      textColor(7);
      write(' ', toStringColour(user[pointer].clSetting), ' ');
      textBackground(Black);
   end;
end;

procedure profile;
const
   BUTTON_X = 30;
   BUTTON_Y = 40;
var
   key: char;
   flag: integer;
begin
   topBar('PROFILE');
   blackScr;
   gotoxy(1, 4);
   userProfileView(user_id);
   gotoxy(BUTTON_X, BUTTON_Y);
   write('EDIT PROFILE');
   flag := 0;
   repeat
      key := readkey;
      if (key = #0) and (key <> #27)
      then begin
              key := readkey;
              case key of
                 #75: mainMenu(0);
                 #72: begin
                         gotoxy(BUTTON_X, BUTTON_Y);
                         textBackground(Black);
                         textColor(White);
                         write('EDIT PROFILE');
                         flag := 0;
                      end;
                 #80: begin
                         gotoxy(BUTTON_X, BUTTON_Y);
                         textBackground(colour);
                         textColor(Black);
                         write('EDIT PROFILE');
                         flag := 1;
                      end;
              end;
              textBackground(Black);
              textColor(White);
              lowvideo;
           end
   until (key = #75) or (key = #13);

   if (key = #13) and (flag = 1)
   then userEdit(user_id)
   else mainMenu(0);
end;

procedure pgmeListItem(const inArray: TPgmeArray; const index: integer; full: integer);          //show a record in a programme array
begin
   with inArray[index] do
   begin
      writeln(' University Name: ', u_name);
      writeln(' Category Number: ', cat_no);
      writeln(' Programme Abbr.: ', pgme);
      writeln(' Programme Name: ', pgme_full);
      if median = -1
      then writeln(' Median Score: N/A')
      else writeln(' Median Score: ', median);
      writeln(' Score Counting Method: ', method);
      if full = 1 then
      writeln('================================================================================')
      else
      writeln('=======================================');
   end;
end;

procedure pgmeListview(pointer, page_count, max, choice: integer; var max_page: integer);
const
   MAX_ITEM = 5;
var
   i, end_pointer: integer;
begin
   textBackground(Black);
   window(20, 4, 100, 50);
   clrscr;
   if max mod MAX_ITEM = 0
   then max_page := max div MAX_ITEM
   else max_page := max div MAX_ITEM + 1;

   if max = 0 then max_page := 1;

   end_pointer := pointer + MAX_ITEM - 1;
   if end_pointer > max then end_pointer := max;

   writeln('================================================================================');
   for i := pointer to end_pointer do
   begin
      case choice of
         1: pgmeListItem(ugc, i, 1);
         2: pgmeListItem(selfFin, i, 1);
         3: pgmeListItem(sssdp, i, 1);
      end;
   end;
   gotoxy(12, 46); write('PRESS PgUp/PgDn TO SCROLL | F1 F2 F3 TO SELECT FUNDING');
   gotoxy(38, 47); write('<', page_count, '/', max_page, '>');
end;

procedure pgmeTab(const choice: integer);         //tab below topBar
var
   t_item: array[1..3] of string;
   i: integer;
begin
   t_item[1] := '    1.UGC-FUNDED    ';
   t_item[2] := '  2.SELF-FINANCING  ';
   t_item[3] := '       3.SSSDP      ';
   textBackground(Black);
   window(20, 2, 100, 4);
   clrscr;
   gotoxy(1, 2);
   for i := 1 to 3 do begin
      if i = choice then
         textBackground(colour)
      else
         textBackground(Black);
      write(t_item[i]);
   end;
end;

procedure pgme;
const
   MAX_ITEM = 5;
var
   key: char;
   index, page, page_max, max_index: integer;
   pgme: 1..3;
begin
   topBar('PROGRAMMES');      //initialization
   max_index := numUgc;
   page_max := 1;
   index := 1;
   page := 1;
   pgme := 1;
   pgmeTab(1);
   pgmeListview(index, page, max_index, 1, page_max);
   repeat
      key := readkey;
      if (key = #0) and (key <> #27)
      then begin
              key := readkey;
              case key of
                 #75: mainMenu(0);
                 #73: begin                     //pgup
                         index := index - MAX_ITEM;
                         page := page - 1;
                      end;
                 #81: begin                     //pgdn
                      //to prevent index > max_index, check its value first
                         if index + MAX_ITEM < max_index
                         then index := index + MAX_ITEM;
                         page := page + 1;
                      end;
                 #59: begin                     //F1
                         max_index := numUgc;
                         index := 1;
                         page := 1;
                         pgme := 1;
                      end;
                 #60: begin                     //F2
                         max_index := numSelfFin;
                         index := 1;
                         page := 1;
                         pgme := 2;
                      end;
                 #61: begin                     //F3
                         max_index := numSssdp;
                         index := 1;
                         page := 1;
                         pgme := 3;
                      end;
              end;
           end;
      if (index <= 0) or (page <= 0) then
      begin
         index := 1;
         page := 1;
      end;
      if page > page_max then page := page_max;
      pgmeTab(pgme);
      pgmeListview(index, page, max_index, pgme, page_max);
   until key = #75;
end;

procedure calDisplaySubject;
begin
   writeln;
   writeln(' ':3, 'Chinese: ');
   writeln(' ':3, 'English: ');
   writeln(' ':3, 'Maths: ');
   writeln(' ':3, 'LS: ');
   writeln(' ':3, toString(user[user_id].x1), ': ');
   writeln(' ':3,  toString(user[user_id].x2), ': ');
   write(' ':3,  toString(user[user_id].x3), ': ');
end;

function calBest5(arr: TSubjectArray): integer;
var
   i, sum: integer;
begin
   if (low(arr) > high(arr)) or ((arr[5] = 0) and (arr[6] = 0) and (arr[7] = 0))    //invalid data
   then
      calBest5 := -1
   else begin
           sum := 0;
           qSortSubject(arr, low(arr), high(arr));   //find highest
           for i := 7 downto 3 do
              sum := sum + arr[i];
           calBest5 := sum;
        end;
end;

function calOneElective(arr: TSubjectArray): integer;
var
   i, sum: integer;
begin
   if (low(arr) > high(arr)) or ((arr[5] = 0) and (arr[6] = 0) and (arr[7] = 0))
   then
      calOneElective := -1
   else begin
           sum := 0;
           for i := 1 to 4 do
              sum := sum + arr[i];
           qSortSubject(arr, 5, 7);              //electives
           sum := sum + arr[7];   //add only the largest
           calOneElective := sum;
        end;
end;

procedure calDisplayGrade(const arr: TSubjectArray; choice: integer);
var
   i: integer;
begin
   window(45, 3, 48, 10);
   textBackground(Black);
   clrscr;
   lowvideo;
   for i := 1 to 7 do
   begin
      if i = choice
      then
         textBackground(colour)
      else
         textBackground(Black);
      writeln(gradeToString(arr[i]));
   end;
   textBackground(Black);
   window(50, 11, 55, 12);
   clrscr;
   if choice = 8 then
      textBackground(colour)
   else
      textBackground(Black);
   write('Enter');
end;

function calLowestGrade(const choice: integer):integer;
begin
   case choice of
      1..4: calLowestGrade := 1;
      5..7: calLowestGrade := 0;
   end;
end;

function calIsValid(const arr: TSubjectArray): boolean;
begin
   if (arr[1] < 3) or (arr[2] < 3) or (arr[3] < 2) or
   (arr[4] < 2) or ((arr[5] < 2) and (arr[6] < 2)) and ((arr[7] < 2)) then      //check if core and elective subjects pass lowest requirement
      calIsValid := false         //exit(false)
   else calIsValid := true;       //exit(true);
end;

procedure calIni(var arr: TSubjectArray);
begin
   with user[user_id] do
   begin
      arr[1] := Chi;
      arr[2] := Eng;
      arr[3] := Maths;
      arr[4] := LS;
      arr[5] := x1gr;
      arr[6] := x2gr;
      arr[7] := x3gr;
   end;
end;

procedure calDisplayPgme(cx, cy: integer; indexLow, indexHigh: integer);
var
   i: integer;
begin
   window(cx, cy, cx + 40, cy + 30);
   textBackground(Black);
   clrscr;
   for i := indexHigh downto indexLow do
      pgmeListItem(ugc, i, 0);
end;

procedure calculator;         //calculator supports only UGC-Funded programmes
const
   MAX_SUBJECT = 7;
var
   key: char;
   calArray: TSubjectArray;
   subject_choice, best5, oneX, best5Index, oneXIndex, best5_temp, oneX_temp: integer;
begin
   topBar('CALCULATOR');
   blackScr;
   subject_choice := 1;
   calIni(calArray);
   calDisplaySubject;
   calDisplayGrade(calArray, subject_choice);
   textBackground(Black);
   window(20, 13, 100, 16);
   clrscr;
   writeln(' Suggested subjects');
   writeln('=============================================================================');
   writeln('            BEST 5                                    4C+1X                  ');

   repeat
      key := readkey;
      if (key <> #0) and (key <> #27)
      then begin
              //key := readkey;
              case key of
                 #75: mainMenu(0);                             //up
                 #72: begin
                         subject_choice := subject_choice - 1;
                         if subject_choice < 1 then subject_choice := 1;
                      end;
                 #80: begin                                    //down
                         subject_choice := subject_choice + 1;
                         if subject_choice > MAX_SUBJECT + 1 then subject_choice := MAX_SUBJECT + 1;
                      end;
                 #13: begin
                         case subject_choice of
                            1..7: calArray[subject_choice] := gradePicker(50, subject_choice + 2, calLowestGrade(subject_choice), 7, colour);
                            8: begin
                                  best5 := calBest5(calArray);
                                  oneX := calOneElective(calArray);
                                  best5_temp := best5;
                                  oneX_temp := oneX;

                                  best5Index := binSearchPgmeMedian(ugc, best5, 1, numUgc);
                                  while (best5Index = -1) and (best5_temp > 0) do
                                  begin
                                     dec(best5_temp);
                                     best5Index := binSearchPgmeMedian(ugc, best5_temp, 1, numUgc);
                                  end;

                                  oneXIndex := binSearchPgmeMedian(ugc, oneX, 1, numUgc);
                                  while (oneXIndex = -1) and (oneX_temp > 0) do
                                  begin
                                     dec(oneX_temp);
                                     oneXIndex := binSearchPgmeMedian(ugc, oneX_temp, 1, numUgc);
                                  end;

                                  if (calIsValid(calArray) = true) and ((best5 > 0) or (oneX > 0) or (not (best5Index = -1)) or (not (oneXIndex = -1))) then
                                  begin
                                     textBackground(Black);
                                     window(20, 13, 100, 16);
                                     clrscr;
                                     writeln(' Suggested subjects');
                                     writeln('=============================================================================');
                                     writeln('            BEST 5: ', best5,'                                  4C+1X: ', oneX);
                                     calDisplayPgme(20, 17, best5Index - 3, best5Index);     //find programmes with max. 3 marks lower than best5 score
                                     calDisplayPgme(60, 17, oneXIndex - 3, oneXIndex);       //find programmes with max. 3 marks lower than oneX score
                                  end
                                  else begin    //display warning
                                          textBackground(Black);
                                          window(20, 13, 100, 50);
                                          clrscr;
                                          writeln(' Suggested subjects  (**INVALID INPUT**)');
                                          writeln('=============================================================================');
                                       end;
                               end;
                         end;
                      end;
              end;
           end;
      calDisplayGrade(calArray, subject_choice);
   until key = #75;
end;

procedure settings;
var
   key: char;
begin
   textBackground(colour);
   window(20, 1, 100, 50);
   clrscr;
   gotoxy(TITLE_X, TITLE_Y);write('SETTINGS');
   blackScr;
   gotoxy(3, 5);
   write('Accent Colour: ');
   colour := colourPicker(24, 8, colour);
   user[user_id].clSetting := colour;
   window(20, 1, 100, 50);
   gotoxy(18, 6);
   write(toStringColour(colour));
   saveUser(numDb);

   //refresh
   textBackground(colour);
   window(20, 1, 100, 50);
   clrscr;
   gotoxy(TITLE_X, TITLE_Y);write('SETTINGS');
   blackScr;
   gotoxy(3, 5);
   write('Accent Colour: ');
   window(20, 1, 100, 50);
   gotoxy(18, 6);
   write(toStringColour(colour));

   repeat
      key := readkey;
      if (key = #0) and (key <> #27)
      then begin
              key := readkey;
              case key of
                 #75: mainMenu(0);
              end;
           end
   until key = #75;
end;

procedure editPgme(index: integer; inArr: TPgmeArray);
var
   median_temp: string;
   median_temp_code: integer;
begin
   window(22, 15, 100, 50);
   clrscr;
   with inArr[index] do
   begin
      textBackground(Yellow);
      textColor(Black);
      gotoxy(24, 1);
      writeln('Edit ', cat_no);
      textBackground(Black);
      textColor(7);
      writeln('University name: ');
      readln(u_name);
      writeln('Category number: JS');
      readln(cat_no);
      while length(cat_no) <> 4 do
      begin
         write(' Input only 4 digits!');
         delay(500);
         window(22, 18, 100, 50);
         clrscr;
         writeln('Category number: JS');                  //change of funding category is not allowed
         readln(cat_no);
      end;
      cat_no := 'JS' + cat_no;
      writeln('Programme Abbreviation: ');
      readln(pgme);
      writeln('Programme full name: ');
      readln(pgme_full);
      writeln('Median (-1: not available; Range: 0 - 60): ');
      readln(median_temp);
      val(median_temp, median, median_temp_code);
      while (median < -1) or (median > 60) or (median_temp_code > 0) do
      begin
         write(' Median not between -1 and 60!');
         delay(500);
         window(22, 24, 100, 50);
         clrscr;
         writeln('Median (-1: not available; Range: 0 - 60): ');
         readln(median_temp);
         val(median_temp, median, median_temp_code);
      end;
      writeln('Score counting method: ');
      readln(method);
   end;
   savePgme;
   writeln('CHANGES SAVED!');
end;

procedure editPgmeSelect(index: integer; var inArr: TPgmeArray);
var
   key: char;
   choice: integer;

procedure selector(choice: integer);
var
   i: integer;
   ch: array[1..3] of string;
begin
   ch[1] := ' EDIT ';
   ch[2] := ' DELETE';
   ch[3] := ' CANCEL ';
   textBackground(Black);
   window(24, 15, 40, 18);
   clrscr;
   for i := 1 to 3 do
   begin
      if choice = i then
         textBackground(Yellow)
      else
         textBackground(Black);
      writeln(ch[i]);
   end;
end;

begin
   choice := 3;
   selector(choice);
   repeat
      key := readkey;
      if key = #0 then
      begin
         key := readkey;
         case key of
            #72: dec(choice); //up
            #80: choice := (choice + 1) mod 3; //down
         end;
         if choice < 1 then choice := 3;
         selector(choice);
      end;
   until key = #13;
   case choice of
      1: editPgme(index, inArr);
      2: begin
            inArr[index].pgme := DELETE_MARK;       //delete and save
            savePgme;
            clrscr;
         end;
      3: begin
            textBackground(Black);
            clrscr;
         end;
   end;
end;

function catNoException(key: string): string;             //check cat_no input
var
   valid: boolean;
begin
   valid := true;
   if (length(key) <> 4) then
   begin
      catNoException := 'Input 4 digits ONLY.';
      valid := false;
   end;
   if (length(key) = 0) then
   begin
      catNoException := 'No input.';
      valid := false;
   end;
   if valid then catNoException := ''; //gives a nil output
end;

procedure searchBoxAlt;
begin
   textBackground(Yellow);
   window(49, 5, 90, 5);
   clrscr;
   textColor(Black);
end;

procedure adminPgme;
var
   key: char;
   sText, errorText: string;
   pointerUgc, pointerSssdp, pointerSelf: integer;
   close: boolean;
begin
   topBar('EDIT PROGRAMME');
   blackScr;
   gotoxy(3, 4); writeln('Search(DIGITS AFTER "JS"): ');
   write('================================================================================');
   close := false;
   repeat
      cursoron;
      searchBoxAlt;
      readln(sText);
      textBackground(Black);
      window(20, 7, 100, 50);
      clrscr;
      errorText := catNoException(sText);
      textColor(7);
      if length(errorText) = 0 then
      begin
         pointerUgc := binSearchPgmeCat(ugc, sText, 1, numUgc);
         pointerSssdp := binSearchPgmeCat(sssdp, sText, 1, numSssdp);
         pointerSelf := binSearchPgmeCat(selfFin, sText, 1, numSelfFin);
         if (pointerUgc = -1) and (pointerSssdp = -1) and (pointerSelf = -1)
         then begin
                 cursoroff;
                 write('        Programme not found.');
              end
         else begin
                 cursoroff;
                 if pointerUgc > 0 then
                 begin
                    pgmeListItem(ugc, pointerUgc, 1);
                    editPgmeSelect(pointerUgc, ugc);        //invoke select box
                 end;
                 if pointerSssdp > 0 then
                 begin
                    pgmeListItem(sssdp, pointerSssdp, 1);
                    editPgmeSelect(pointerSssdp, sssdp);
                 end;
                 if pointerSelf > 0 then
                 begin
                    pgmeListItem(selfFin, pointerSelf, 1);
                    editPgmeSelect(pointerSelf, selfFin);
                 end;
              end;
      end
      else
         write('        ', errorText);       //display error
      key := readkey;
      if key = #0
      then begin
              key := readkey;
              case key of
              #75: begin
                      close := true;
                      mainMenu(0);
                   end;
              end;
           end;
   until close;
end;

procedure adminEditUser;
var
   key: char;
   sText: string;
   close: boolean;
   pointer: integer;
begin
   topBar('EDIT USER');
   blackScr;
   gotoxy(3, 4); writeln('Search: ');
   writeln('================================================================================');
   close := false;
   sText := '';
   searchBox(31, sText);
   repeat
      key := readkey;
      if key <> #0
      then begin
              case key of
                 #75: begin
                         close := true;
                         mainMenu(0);
                      end;
                 #13: begin                          //do checking action here
                         pointer := binSearchUser(sText);
                         if pointer <> -1
                         then begin
                                 textBackground(Black);
                                 window(20, 8, 100, 50);
                                 clrscr;
                                 userProfileView(pointer);
                                 writeln;
                                 writeln;
                                 writeln;
                                 write('        Press ENTER Again to DELETE THIS USER ');
                                 key := readkey;
                                 if key = #13
                                 then begin
                                          user[pointer].Username := DELETE_MARK;
                                          saveUser(numDb);
                                          writeln('        [DELETED]');
                                          close := true;
                                          delay(1500);
                                          mainMenu(0);
                                      end;
                              end
                         else begin                           //user not found handling
                                 textBackground(Black);
                                 window(20, 8, 100, 50);
                                 clrscr;
                                 write('        User not found. ');
                              end;
                       end;
              else
                 wordInput(sText, key, key);
                 searchBox(31, sText);
              end;
           end
   until close;
end;

procedure menuItem;
var
   i: integer;
begin
   cursoroff;
   textBackground(Black);
   window(2, 2, 19, MAX_Y_WINDOW_SIZE - 2);
   clrscr;
   for i := 1 to mcount do begin
      if (menu_item = i) then
         textBackground(colour)
      else
         textBackground(Black);
      writeln;
      writeln;
      writeln(mitem[i]);
      writeln;
      writeln;
   end;
end;

//DISPLAY MAIN MENU WITH NO ACCENT COLOUR
procedure menuItemOff;
var i: integer;
begin
   cursoroff;
   textBackground(Black);
   window(2, 2, 19, MAX_Y_WINDOW_SIZE - 2);
   clrscr;
   for i := 1 to mcount do begin
      writeln;
      writeln;
      textBackground(Black);
      writeln(mitem[i]);
      writeln;
      writeln;
   end;
end;

procedure readMenu;
var i: integer;
begin
   if admin then
      assign(mfile, 'admin_main_menu.txt')
   else
      assign(mfile, 'user_main_menu.txt');
   reset(mfile);
   mcount := 0;
   while not eof(mfile) do begin
      mcount := mcount + 1;
      readln(mfile, mitem[mcount]);
   end;
   for i := 1 to mcount do
      mitem[i] := ' ' + mitem[i] + ' '; {add space to increase text readibility}
   close(mfile);
end;

procedure mainMenu(flag: integer);
var
   key: char;
label
   launch;
begin
   readMenu;
   window(2, 2, 19, MAX_Y_WINDOW_SIZE - 2);
   clrscr;
   menuItem;
   if flag = 1 then goto launch;  //have to use goto to skip the loop
   repeat
      key := readkey;
      if (key = #0) and (key <> #27)
      then begin
              key := readkey;
              case key of
                 #77: begin         //Right key, same function as enter
                         menuItemOff;
                         if admin then
                         begin
                            case menu_item of
                               1: home;
                               2: search;
                               3: adminEditUser;
                               4: adminPgme;
                            end;
                         end

                         else
                         begin
                            case menu_item of
                               1: home;
                               2: search;
                               3: profile;
                               4: pgme;
                               5: calculator;
                               6: settings
                            end;
                         end;
                      end;
                 #72: menu_item := menu_item - 1;                //Up key
                 #80: menu_item := (menu_item + 1) mod mcount;   //Down key
              end;
              if (menu_item = 0) then menu_item := mcount;
           end;
      menuItem;
   until key = #13;

   launch:
   menuItemOff;
   if admin then
   begin
      case menu_item of
         1: home;
         2: search;
         3: adminEditUser;
         4: adminPgme;
         5: welcomeScreen;
      end;
   end
   else
   begin
      case menu_item of
         1: home;
         2: search;
         3: profile;
         4: pgme;
         5: calculator;
         6: settings;
         7: welcomeScreen;
      end;
   end;
end;

procedure passwordException(key, value: string);
var
   ch: string;
begin
   if admin
   then
      ch := 'admin'
   else
      ch := 'user';

   if (length(value) = 0) then
   begin
      write('Password not entered.');
      delay(500);
      write(' Enter again.');
      delay(2000);
   end
   else if (length(value) <= 4) then
        begin
           write('Password contains more than 4 characters.');
           delay(500);
           write(' Enter again.');
           delay(2300);
        end
        else if (length(key) = 0) then
             begin
                write(ch, ' name not entered.');
                delay(500);
                write(' Enter again.');
                delay(2000);
             end
             else begin
                     write('Password or ', ch,' name invalid.');
                     delay(500);
                     write(' Enter again.');
                     delay(2000);
                  end;
end;

procedure passwordHandler;
var
   id, pw: string;
   ch: char;
   valid: boolean;
   index: integer;
begin
   valid := false;
   cursoron;
   while not valid do begin
      window(15, 15, 80, 30); clrscr;
      writeln('=================================================================');
      write('||                                                              ||');
      write('||                                                              ||');
      write('||                                                              ||');
      write('||                                                              ||');
      write('||                                                              ||');
      write('||                                                              ||');
      write('||                                                              ||');
      write('||                                                              ||');
      write('||                                                              ||');
      write('||                                                              ||');
      write('||                                                              ||');
      write('||                                                              ||');
      write('||                                                              ||');
      write('=================================================================');

   {input username and password}
      gotoxy(8, 2);
      if admin = true then  {Login as admin}
         begin writeln;
               gotoxy(8, 3);
               write('ADMIN ID: ');
               readln(id);
         end
      else
         begin {Login as user}
            writeln;
            gotoxy(8, 3);
            write('USERNAME: ');
            readln(id);
         end;
      gotoxy(8, 6);
      write('PASSWORD: '); pw := '';
      repeat
         ch := readkey;
         wordInput(pw, ch, '*');
      until (ch = #13);

      //PASSWORD CHECKING
      gotoxy(8, 8);
      //check admin
      if admin then
      begin
         if ((id = ADMIN_USERNAME) and (pw = ADMIN_PW))
         then begin
                 valid := true;
                 colour := DEFAULT_COLOUR;
                 menu_item := 1;
                 mainMenu(1);
              end
         //EXCEPTION HANDLING
         else passwordException(id ,pw);
      end //end of then part

      //check user
      else begin
         for index := 1 to numDb do begin
            with user[index] do
               if (id = Username) and (pw = UserPW)
               then begin
                       user_id := index;
                       valid := true;
                       colour := user[user_id].clSetting;
                       menu_item := 1;
                       mainMenu(1);
                       break;
                    end
               end; //end of for loop
      end; //end of else part
             //EXCEPTION HANDLING FOR USER
      if (not admin) and (not valid)
      then passwordException(id ,pw);
   end; //end of while loop
end;

procedure userReg(var user_count: integer);
var
   ch, key: char;
   pw, temp: string;
begin
   admin := false;
   cursoron;
   window(1, 1, 100, 50);
   textBackground(Black);
   clrscr;
   textBackground(DEFAULT_COLOUR);
   gotoxy(35, 5);
   write('           REGISTER          ');
   append(userDb);
   textBackground(Black);
   textColor(White);
   lowvideo;
   window(30, 10, 100, 50);
   user_count := user_count + 1;
   with user[user_count] do
   begin
      write('User name: '); readln(temp);
      while (length(temp) = 0) or (binSearchUser(temp) <> -1) do
      begin
         if length(temp) = 0 then
         begin
            write('This is a mandatory field. Cannot be null.');
            delay(2000);
            clrscr;
         end

         else
         begin
            write('Name used. Use a different username.');
            delay(2000);
            clrscr;
         end;

         gotoxy(1, 1);
         write('User name: '); readln(temp);
      end;
      Username := temp;
      writeln;
      write('Password( >4 chararcters ): '); pw := '';
      repeat
         ch := readkey;
         wordInput(pw, ch, '*');
      until (ch = #13);
      while length(pw) <= 4 do
      begin
         if length(pw) = 0 then
         begin
            window(30, 13, 100, 15);
            write('This is a mandatory field. Cannot be null.');
            delay(2000);
            clrscr;
         end

         else
         begin
            window(30, 13, 100, 15);
            write('Password should contain >4 characters.');
            delay(2000);
            clrscr;
         end;
         window(30, 12, 100, 50);
         clrscr;
         write('Password( >4 chararcters ): '); pw := '';
         repeat
            ch := readkey;
            wordInput(pw, ch, '*');
         until (ch = #13);
      end;
      UserPW := pw;

      writeln;
      writeln;
      write('Name: '); readln(Name);
      writeln;
      write('Sex(M/F): ');
      Sex := sexPicker(40, 16, colour);
      writeln(Sex);
      window(30, 18, 100, 50);
      clrscr;
      write('Expected Chinese result: ');
      Chi := gradePicker(55, 18, 1, 7, colour);
      write(gradeToString(Chi));
      window(30, 20, 100, 50);
      clrscr;
      write('Expected English result: ');
      Eng := gradePicker(55, 20, 1, 7, colour);
      write(gradeToString(Eng));
      window(30, 22, 100, 50);
      clrscr;
      write('Expected Maths result: ');
      Maths := gradePicker(55, 22, 1, 7, colour);
      write(gradeToString(Maths));
      window(30, 24, 100, 50);
      clrscr;
      write('Expected LS result: ');
      LS := gradePicker(55, 24, 1, 7, colour);
      write(gradeToString(LS));
      window(30, 26, 100, 50);
      clrscr;
      write('Elective 1: ');
      x1 := electivePicker(42, 26, colour);
      write(toString(x1));
      window(30, 28, 100, 50);
      clrscr;
      write('Elective 2: ');
      x2 := electivePicker(42, 28, colour);
      write(toString(x2));
      window(30, 30, 100, 50);
      clrscr;
      write('Elective 3: ');
      x3 := electivePicker(42, 30, colour);
      write(toString(x3));
      window(30, 32, 100, 50);
      clrscr;
      write('Expected Elective 1 result: ');
      x1gr := gradePicker(60, 32, 0, 7, colour);
      write(gradeToString(x1gr));
      window(30, 34, 100, 50);
      clrscr;
      write('Expected Elective 2 result: ');
      x2gr := gradePicker(60, 34, 0, 7, colour);
      write(gradeToString(x2gr));
      window(30, 36, 100, 50);
      clrscr;
      write('Expected Elective 3 result: ');
      x3gr := gradePicker(60, 36, 0, 7, colour);
      write(gradeToString(x3gr));
      window(30, 40, 100, 50);
      highvideo;
      clSetting := DEFAULT_COLOUR;
      writeln('Press ENTER to confirm registration.');
      repeat
         key := readkey;
         case key of
            #27: break;
            #13: begin
                    writeln(userDb, Username);
                    writeln(userDb, UserPW);
                    writeln(userDb, Name);
                    writeln(userDb, Sex);
                    writeln(userDb, Chi, ' ', Eng, ' ',Maths, ' ',LS);
                    writeln(userDb, ord(x1), ' ',ord(x2), ' ',ord(x3));
                    writeln(userDb, x1gr, ' ',x2gr, ' ',x3gr);
                    writeln(userDb, clSetting);
                    writeln(userDb);
                 end;
         end;
      until (key = #13) or (key = #27);
   end;
   write('REGISTER SUCCESSFUL');
   delay(1000);
   close(userDb);
   lowvideo;
   user_id := user_count;
   menu_item := 1;
   mainMenu(1);
end;

procedure loginHandler(const num: integer);
var
   i: integer;
   ch: array[1..3] of string;
begin
   textBackground(Black);
   window(28, 25, 46, 31);
   clrscr;
   cursoroff;
   ch[1] := ' ADMIN LOGIN    ';
   ch[2] := ' USER LOGIN     ';
   ch[3] := ' REGISTER       ';
   for i := 1 to 3 do begin
      if num = i then
         begin
            textBackground(DEFAULT_COLOUR);
            textColor(Black);
         end
      else begin
              textBackground(Black);
              textColor(White);
           end;
      lowvideo;
      writeln(ch[i]);
      writeln;
   end;
end;

procedure welcomeScreen;
var
   key: char;
begin
   key := #0;  //prevent crash
   colour := DEFAULT_COLOUR;
   window(1, 1, 100, 50);
   textBackground(Black);
   clrscr;
   highvideo;
   slideUpAnim(23, 40, 20, 13, 'Welcome To University Programme Information System');
   delay(20);
   lowvideo;
   slideUpAnim(28, 40, 24, 10, ' ADMIN LOGIN');
   delay(20);
   lowvideo;
   slideUpAnim(28, 40, 26, 10, ' USER LOGIN');
   delay(20);
   lowvideo;
   slideUpAnim(28, 40, 28, 10, ' REGISTER');
   login_choice := 1;
   loginHandler(login_choice);
   repeat
      if ((key = #0) or (key = #13) or (key = #72) or (key = #80)) and (key <> #27)
      then begin
              key := readkey;
              case key of
                 #72: login_choice := login_choice - 1;  //up
                 #80: login_choice := (login_choice + 1) mod 3; //down
                 #13: begin
                         case login_choice of
                            1: begin
                                  admin := true;
                                  passwordHandler;
                               end;
                            2: begin
                                  admin := false;
                                  passwordHandler;
                               end;
                            3: begin
                                  admin := false;
                                  userReg(numDb);
                               end;
                         end;
                      end;
               end;
            end;
      if (login_choice = 0) then login_choice := 3;
      loginHandler(login_choice);
   until (key = #27) or (key = #13);
   if key = #27 then halt;
end;

procedure readDb(var user_count, ugc_count, self_fin_count, sssdp_count, cal_count: integer);
begin
   assign(userDb, 'user_db.txt');
   assign(ugcDb, 'ugc_db.txt');
   assign(selfFinDb, 'self_financing_db.txt');
   assign(sssdpDb, 'sssdp_db.txt');
   assign(cal_file, 'calendar.txt');
   reset(ugcDb);
   reset(userDb);
   reset(selfFinDb);
   reset(sssdpDb);
   reset(cal_file);
   user_count := 0;
   ugc_count := 0;
   self_fin_count := 0;
   sssdp_count := 0;
   cal_count := 0;
   //READ USERDB
   while not eof(userDb) do
   begin
      user_count := user_count + 1;
      with user[user_count] do
      begin
         readln(userDb, Username);
         readln(userDb, UserPW);
         readln(userDb, Name);
         readln(userDb, Sex);
         readln(userDb, Chi, Eng, Maths, LS);
         readln(userDb, ord(x1), ord(x2), ord(x3));
         readln(userDb, x1gr, x2gr, x3gr);
         readln(userDb, clSetting);
         readln(userDb);
      end
   end;
   //READ JUPASDB
   while not eof(ugcDb) do
   begin
      ugc_count := ugc_count + 1;
      with ugc[ugc_count] do
      begin
         readln(ugcDb, u_name);
         readln(ugcDb, cat_no);
         readln(ugcDb, fund);
         readln(ugcDb, pgme);
         readln(ugcDb, pgme_full);
         readln(ugcDb, median);
         readln(ugcDb, method);
         readln(ugcDb);
      end
   end;
   //READ EAPPDB
   while not eof(selfFinDb) do
   begin
      self_fin_count := self_fin_count + 1;
      with selfFin[self_fin_count] do
      begin
         readln(selfFinDb, u_name);
         readln(selfFinDb, cat_no);
         readln(selfFinDb, fund);
         readln(selfFinDb, pgme);
         readln(selfFinDb, pgme_full);
         readln(selfFinDb, median);
         readln(selfFinDb, method);
         readln(selfFinDb);
      end
   end;
   //READ OVERSEADB
   while not eof(sssdpDb) do
   begin
      sssdp_count := sssdp_count + 1;
      with sssdp[sssdp_count] do
      begin
         readln(sssdpDb, u_name);
         readln(sssdpDb, cat_no);
         readln(sssdpDb, fund);
         readln(sssdpDb, pgme);
         readln(sssdpDb, pgme_full);
         readln(sssdpDb, median);
         readln(sssdpDb, method);
         readln(sssdpDb);
      end
   end;
   //READ CALENDAR FOR IMPORTANT DATES
   while not eof(cal_file) do
   begin
      cal_count := cal_count + 1;
      with cldar[cal_count] do
      begin
         readln(cal_file, keydate_temp);       //use a variable to hold the date string
         keydate := StrToDate(keydate_temp);   //convert string to TDateTime
         readln(cal_file, content);
         readln(cal_file);
      end
   end;

   close(userDb);
   close(ugcDb);
   close(selfFinDb);
   close(sssdpDb);
   close(cal_file);
end;

begin
   readDb(numDb, numUgc, numSelfFin, numSssdp, numCal);
   qSortUser(1, numDb);
   saveUser(numDb);
   menu_item := 1;
   welcomeScreen;                 //if you would like to test some procedures, just comment this line
end.
