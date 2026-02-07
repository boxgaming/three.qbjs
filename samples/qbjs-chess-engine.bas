Option Explicit
Export NewGame, Move, AIMove, Moves, BoardPieces, Turn, IsCheck, IsCheckMate, IsFinished
Dim Shared sloaded As Integer
Dim Shared jsChessEngine As Object
Dim Shared As Object game, state
Dim Shared lastError As String

Dim s As Object
s = Dom.Create("script", document.head)
s.async = true
s.src = "https://cdn.jsdelivr.net/npm/js-chess-engine@1.0.3/dist/js-chess-engine.min.js"
s.onload = @OnLoad

Dim ltimer
While sloaded = 0 And ltimer < 12
    _Delay .1
    ltimer = ltimer + 1
WEnd

$If Javascript Then
    jsChessEngine = window["js-chess-engine"];
$End If
NewGame

Sub OnLoad
    sloaded = -1
End Sub

Sub NewGame
$If Javascript Then
    game = new jsChessEngine.Game();
    state = game.exportJson();
$End If
End Sub

Function Moves(pos As String)
    ReDim As String m(0), move 
    Dim mc As Integer
$If Javascript Then
    var moves = game.moves(pos);
    for (var i=0; i < moves.length; i++) {
        move = moves[i];
$End If
        mc = UBound(m) + 1
        Redim Preserve m(mc) As String
        m(mc) = move
$If Javascript Then
    }
$End If
    Moves = m
End Function

Function BoardPieces
    Dim key, value As String
    Dim board() As String
$If Javascript Then
    for (key in state.pieces) {
        value = state.pieces[key];
$End If
        board(key) = value
$If Javascript Then
    }
$End If
    BoardPieces = board
End Function

Function Move (mstart As String, mend As String)
$If Javascript Then
    try {
        game.move(mstart, mend);
        state = game.exportJson();
        return -1;
    }
    catch (e) {
        lastError = e.message;
        return 0;
    }
$End If
End Function

Sub AIMove (level As Integer)
$If Javascript Then
    game.aiMove(level);
    state = game.exportJson();
$End If
End Sub

Function Turn: Turn = state.turn:  End Function
Function IsCheck: IsCheck = state.check:  End Function
Function IsCheckMate: IsCheckMate = state.checkMate:  End Function
Function IsFinished: IsFinished = state.isFinished:  End Function
Function LastErrorMessage: LastErrorMessage = lastError: End Function