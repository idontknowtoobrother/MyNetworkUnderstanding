import 'dart:io';

abstract class Network {
    
    void connection(sessionId);     /** การเชื่อมต่อ */
    void disconnect();              /** ออกจากการเชื่อมต่อ */
    bool isInSession();             /** ได้อยู่ใน Session รึเปล่า */
    String getCurrentSession();     /** ดึง session ที่อยู่ปัจจุบัน */

}


mixin Session {

    void debugWorld() => print('[Debug World] ${worldBridge}'); /** เอาไว้ดูค่า World ว่ามี Server และ User ไหนใน Server ต่างๆด้วย */

    void debug(info, isRefreshScreen){ // Debug เอาไว้ตอนทำโค้ดเบื้องหลัง

        if(isRefreshScreen) print("\x1B[2J\x1B[0;0H"); // หาก isRefreshScreen == true then เคลียหน้าจอ

        print('[ Information ] $info'); // print [ Information ] ต่อด้วย ค่า debug ที่เราโยนเข้ามาใน function เป็น text

    }

    void _leaveSession(sessionId, user){ /** Leave Session การออกจากเซิฟเวอร์นั้นๆ */
        
        var _newSessionData = []; // สร้าง List ขึ้นมาใหม่เพื่อรอเก็บ User
        
        for(var userInSession in worldBridge[sessionId]){ // Loop เพื่อเพิ่มค่าเข้า List ใหม่โดยที่เราจะยกเว้น User ที่ต้องการ Leave เอาไว้

            if(userInSession != user){ // condition หาก user ที่จะ leave ออก ไม่ตรงกับ user ที่มีอยู่แล้วจะทำการ เพิ่มเข้าไปใน List ใหม่

                _newSessionData.add(userInSession);

            }

        }

        if(_newSessionData.length < 1){ /** หาก Session นั้นๆไม่มีคนอยู่แล้วมันจะลบทิ้งทันที = null */

            worldBridge.remove(sessionId);

        }else{ /** หาก Session นั้นยังมีคนอยู่ก็จะเหลือไว้แค่คนอยู่ และเซ็ทค่าใหม่เข้าไปโดยที่เอาคนที่ leave ออก */

            worldBridge[sessionId] = _newSessionData;

        }

        debug('❌ Leaved Session - (🌐 ${sessionId}):(💬 ${user}) .', true); /** ดูค่า Session World */

    }


    bool _joinSession(sessionId, user, currentSession){ /** เอาไว้ Join Session */

        if(_isDuplicateConnectSession(sessionId, currentSession)) return false;  // ดักการ join session ที่ต้องการนั้นเป็น session เดิมที่อยู่ๆแล้วรึเปล่า

        if(_isSessionValid(sessionId)){ // เช็คว่า Session นั้นมีอยู่รึเปล่าหากมีอยู่จะส่ง User เข้าไปทันที
            _addToSession(sessionId, user);
            return true;
        }

        /** หากไม่มี Session อยู่จะทำการส้รางขึ้นมาใหม่และ เพิ่ม User เข้าไปใน Session นั้นๆ */ 
        worldBridge[sessionId] = [user];

        return true;
    }

    void _addToSession(sessionId, user){ /** เพิ่ม User เข้า Session */

        var _newSessionData = []; // สร้าง List ขึ้นมาใหม่เพื่อรอเก็บ User

        for(var _user in worldBridge[sessionId]){ // Loop เพื่อเพิ่ม User เข้า List ใหม่
            _newSessionData.add(_user);
        }

        _newSessionData.add(user); // ตามด้วย user ที่เรียกใช้ function นี้

        worldBridge[sessionId] = _newSessionData; // Set ให้ Session นี้เป็นข้อมูลล่าสุด
    }

    bool _isDuplicateConnectSession(sessionId, requireSession){ /** เช็คการเชื่อมต่อได้ซ้ำกับอันเดิมรึเปล่า */

        bool _isDuppling = sessionId == requireSession; // เช็คการเชื่อมต่อได้ซ้ำกับอันเดิมรึเปล่า session ที่ต้องการ join == session ที่เราอยู่อยู่แล้วรึเปล่า

        if(_isDuppling) debug('⚠️  Already in Session - (🌐 ${sessionId})', true);  // debug ดูหากซ้ำกับ session เดิมที่อยู่อยู่แล้ว

        return _isDuppling; // return ค่ากลับเป็น bool -> true(ซ้อน) - false(ไม่ซ้อน)

    }

    bool _isSessionValid(sessionId){ /** Session นั้นๆมีตัวงตนอยู่รึเปล่า */
        return worldBridge[sessionId] != null; // Session == null (false) - Session != null (true)  
    }

}


class User extends Network with Session {

    /**
     *  _user = ชื่อ User
     *  _currentSession = Session ที่อยู่ณตอนนั้น [ none = ไม่ได้อยู่ใน Session ใดๆ ]
     */
    var _user, _currentSession = 'none';

    /** My constructer :D */
    User(this._user);

    
    void connection(sessionId){ /** Connetion ... */

        if(_joinSession(sessionId, this._user, this.getCurrentSession())){
            this._currentSession = sessionId;
            debug("✔️  Joined Session - (🌐 ${this._currentSession}):(💬 ${this._user}) ." , true);

            debugWorld(); /** ดูค่า Session World */
        }

    }

    void disconnect(){ /** Disconnect ... */

        if(!this.isInSession()) return debug('Your not in any Session (💬${this._user})', true);

        _leaveSession(this.getCurrentSession(), this._user);

        debugWorld(); /** ดูค่า Session World */

        this._currentSession = 'none';
    }


    bool isInSession() => this.getCurrentSession() != 'none'; // Session ที่อยู่ณตอนนั้น [ none = ไม่ได้อยู่ใน Session ใดๆ ]
    String getUsername() => this._user; // Getter ชื่อ user
    String getCurrentSession() => this._currentSession; // Getter Session ที่อยู่
    String getUserInformation() => '💬  ${this._user}'; // Getter ข้อมูลชื่อของ User

}




/** Main System *//** Main System *//** Main System *//** Main System *//** Main System *//** Main System */
/** Main System *//** Main System *//** Main System *//** Main System *//** Main System *//** Main System */

    final worldBridge = {}; /** ค่าโลกของ Session */
    final userList = []; /** ค่า UserList ที่สร้างขึ้น */

    void flushScreen(){
        return print("\x1B[2J\x1B[0;0H");
    }

    String getInformationUserList(){
        var str = '';
        for(var user in userList){
            str += '${user.getUserInformation()}\n   ';
        }
        return str;
    }

    String getInformationWorld(){
        var str = '';
        worldBridge.forEach((k, v){
            str += '🌐  ${k}\n   ';
            for(var user in v){
                str += '   💬  ${user}\n   ';
            }
        });

        return str;
    }

    void createUser(){
        flushScreen();

        print('/* Creating User */');

        stdout.write('Username: ');
        var user = stdin.readLineSync();

        if(user == ''){
            return createUser();
        }

        userList.add(User(user));

        return mainLoop();
    }   

    User getUser(user){
        
        for(var _user in userList){
            if(_user.getUsername() == user){
                return _user;
            }
        }
        return User('null');
    }

    bool isValidUser(user){

        for(var _user in userList){
            if(_user.getUsername() == user){
                return true;
            }
        }

        return false;
    }


    void testJoinSessionMenu(user){
        flushScreen();

        stdout.write("[ Attention ] If you type nothings it's will be return back to control user.\n💬  ${user.getUsername()} - Join Session ? : ");
        var sessionId = stdin.readLineSync();

        if(sessionId == ''){
            return controlUser(user);
        }
        user.disconnect();
        user.connection(sessionId);
        return controlUser(user);
    }

    void testLeaveSessionMenu(user){
        flushScreen();
        
        stdout.write("[ Attention ] If you type nothings it's will be return back to control user.\n💬  ${user.getUsername()} - (Yes / nothings) ? : ");
        var decided = stdin.readLineSync();

        if(decided == ''){
            return controlUser(user);
        }

        user.disconnect();
        return controlUser(user);
    }

    void controlUser(user){
        flushScreen();

        print('/* Controling 💬  ${user.getUsername()} */\n\n   ${getInformationWorld()}\n\n1.Join Session\n2.Leave Session\n3.Back to Test Session\n');

        stdout.write("Choose : ");
        var selection = stdin.readLineSync();

        if(selection == '1'){
            return testJoinSessionMenu(user);
        }else if(selection == '2'){
            return testLeaveSessionMenu(user);
        }else if(selection == '3'){
            return testSession();
        }else{
            return controlUser(user);
        }
    }

    void testSession(){
        flushScreen();

        print('/* Test Session */\n\n   ${getInformationWorld()}\n\n/* UserList */\n   ${getInformationUserList()}\n\nNothings - Back to main menu\n');

        stdout.write("Choose User Control By 'Name' : ");
        var user = stdin.readLineSync();

        if (user == ''){
            return mainLoop();

        }else if(isValidUser(user)){

            return controlUser(getUser(user));

        }else{
            
            flushScreen();
            print('❌  Not found User : ${user}');

            stdin.readLineSync();
            return testSession();
        }

    }

    void mainLoop(){
        flushScreen();

        print('/* Network Session Simulator */\n   1.Create User\n   2.Test Session\n   3.Exit\n\n   ${getInformationUserList()}');
        
        stdout.write("Choose : ");
        var selection = stdin.readLineSync();

        if(selection == '1'){
            return createUser();
        }else if(selection == '2'){
            return testSession();
        }else if(selection == '3'){
            flushScreen();
            print('Exited Network Simmulator.');
            return;
        }else{
            return mainLoop(); 
        }
    }

/** Main System *//** Main System *//** Main System *//** Main System *//** Main System *//** Main System */
/** Main System *//** Main System *//** Main System *//** Main System *//** Main System *//** Main System */



/** Main Program */
main() => mainLoop();
/** Main Program */