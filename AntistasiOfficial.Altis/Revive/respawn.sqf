private ["_unit"];
_unit = _this select 0;
if (!local _unit) exitWith {};
if (_unit getVariable "ASrespawning") exitWith {};
if !([_unit] call AS_fnc_isUnconscious) exitWith {};
if (_unit != _unit getVariable ["owner",_unit]) exitWith {};
if (!isPlayer _unit) exitWith {};
_unit setVariable ["ASrespawning",true];
//_unit enableSimulation true;
["ASrespawning",0,0,3,0,0,4] spawn bis_fnc_dynamicText;
//titleText ["", "BLACK IN", 0];
if (isMultiplayer) exitWith
	{/*
	if (!isNil "deadCam") then
		{
		if (!isNull deadCam) then
			{
			deadCam camSetPos position player;
			deadCam camCommit 1;
			sleep 1;
			deadCam cameraEffect ["terminate", "BACK"];
			camDestroy deadCam;
			};
		};
	*/
	(findDisplay 46) displayRemoveEventHandler ["KeyDown", respawnMenu];
	[_unit,false] remoteExec ["setCaptive"];
	[_unit, false] call AS_fnc_setUnconscious;
	_unit setVariable ["ASrespawning",false];
	//if (captive _unit) then {[_unit,false] remoteExec ["setCaptive"]};
	_unit setDamage 1;
	};
private ["_posicion","_tam","_roads","_road","_pos"];
_posicion = getMarkerPos guer_respawn;
if ([_unit] call AS_fnc_isUnconscious) then {[_unit, false] call AS_fnc_setUnconscious};
_unit setVariable ["ASmedHelped",nil];
_unit setVariable ["ASmedHelping",nil];
_unit setDamage 0;
_unit setVariable ["compromised",0];
if (activeACEMedical) then {
	_unit setVariable ["ACE_isUnconscious",false,true];
	[_unit, _unit] call ace_medical_fnc_treatmentAdvanced_fullHeal;
};
_nul = [0,-1,getPos _unit] remoteExec ["citySupportChange",2];

_hr = round ((server getVariable "hr") * 0.1);
_resourcesFIA = round ((server getVariable "resourcesFIA") * 0.05);

[- _hr, - _resourcesFIA] remoteExec ["resourcesFIA",2];

{
//_x hideObject true;
if (_x != vehicle _x) then
	{
	if (driver vehicle _x == _x) then
		{
		sleep 3;
		_tam = 10;
		while {true} do
			{
			_roads = _posicion nearRoads _tam;
			if (count _roads > 0) exitWith {};
			_tam = _tam + 10;
			};
		_road = _roads select 0;
		_pos = position _road findEmptyPosition [1,50,typeOf (vehicle _unit)];
		vehicle _x setPos _pos;
		};
	}
else
	{
	if (!([_x] call AS_fnc_isUnconscious) and (alive _x)) then
		{
		_x setPosATL _posicion;
		_x setVariable ["ASrearming",false];
		_x doWatch objNull;
		_x doFollow leader _x;
		}
	else
		{
		_x setDamage 1;
		};
	};
//_x hideObject false;
} forEach (units group _unit) + (units rezagados) - [_unit];
removeAllItemsWithMagazines _unit;
_hmd = hmd _unit;
if (_hmd != "") then
	{
	_unit unassignItem _hmd;
	_unit removeItem _hmd;
	};
{_unit removeWeaponGlobal _x} forEach weapons _unit;
//removeBackpack _unit;
//removeVest _unit;
_unit setPosATL _posicion;
_unit setCaptive false;
_unit setUnconscious false;
_unit playMoveNow "AmovPpneMstpSnonWnonDnon_healed";
sleep 4;
_unit setVariable ["ASrespawning",false];