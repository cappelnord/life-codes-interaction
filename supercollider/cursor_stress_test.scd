(

var net = NetAddr("127.0.0.1", 57140);
var n = 300;
var fps = 60;
var pressReleaseProbability = 0.01;

var ids = n.collect {|i| i.asString};

ids.do {|id|
	var pressed = false;
	var startPosition = [5000.rand, 1000.rand];
	net.sendMsg("/lc/cursor/move", id, startPosition[0], startPosition[1]);
	{
		inf.do {
			net.sendMsg("/lc/cursor/moveDelta", id, 20.0.rand2, 20.0.rand2);
			pressReleaseProbability.coin.if {
				pressed.if({
					net.sendMsg("/lc/cursor/release", id);
					pressed = false;
				}, {
					net.sendMsg("/lc/cursor/press", id);
					pressed = true;
				});
			};
			§(1/fps).wait;
		};

	}.fork;
};
)