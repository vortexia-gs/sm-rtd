/**
* Tiny Mann perk.
* Copyright (C) 2023 Filip Tomaszewski
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#define SpeedBoost Int[0]
#define BaseScale Float[0]
#define Scale Float[1]

DEFINE_CALL_APPLY_REMOVE(TinyMann)

public void TinyMann_Init(const Perk perk)
{
	Events.OnPlayerRunCmd(perk, TinyMann_OnPlayerRunCmd);
	Events.OnSoundEx(perk, TinyMann_OnSoundEx);
}

public void TinyMann_ApplyPerk(const int client, const Perk perk)
{
	float fScale = perk.GetPrefFloat("scale", 0.15);

	Cache[client].SpeedBoost = perk.GetPrefCell("boost", 1);
	Cache[client].BaseScale = GetEntPropFloat(client, Prop_Send, "m_flModelScale");
	Cache[client].Scale = fScale;

	//TF2Attrib_SetByDefIndex(client, Attribs.VoicePitch, 1.0 / fScale / 2.0);
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", fScale);

	if (Cache[client].SpeedBoost)
		TF2_AddCondition(client, TFCond_SpeedBuffAlly);
}

public void TinyMann_RemovePerk(const int client, const RTDRemoveReason eRemoveReason)
{
	//TF2Attrib_RemoveByDefIndex(client, Attribs.VoicePitch);
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", Cache[client].BaseScale);

	if (Cache[client].SpeedBoost)
		TF2_RemoveCondition(client, TFCond_SpeedBuffAlly);

	FixPotentialStuck(client);
}

bool TinyMann_OnPlayerRunCmd(const int client, int& iButtons, float fVel[3], float fAng[3])
{
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", Cache[client].Scale);
	return false;
}

bool TinyMann_OnSoundEx(const int client, const char[] sSound, int& iChannel, float& fVol, int& iLevel, int& iPitch)
{
	if (strncmp(sSound, "vo/", 3, false) != 0)
		return false;

	iPitch = RoundToNearest(100.0 + (1.0 / Cache[client].Scale / 2.0 * 10.0));
	return true;
}

#undef SpeedBoost
#undef BaseScale
#undef Scale
