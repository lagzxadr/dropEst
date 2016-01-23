#include "OutcomesCounter.h"

#include <iomanip>
#include <sstream>

void OutcomesCounter::inc(StatType type)
{
	++this->stats[type];
}

int OutcomesCounter::get(StatType type) const
{
	return this->stats[type];
}

OutcomesCounter::OutcomesCounter()
{
	for (int i = 0; i < STAT_SIZE; ++i)
	{
		stats[i] = 0;
	}

	names[OK] = "OK";
	names[NO_SPACER] = "No spacer";
	names[SHORT_SEQ] = "Short";
	names[SPACER_2] = "Spacer2";
	names[SPACER_MISPLACED] = "Spacer misplaced";
}

std::string OutcomesCounter::print(double normalizer) const
{
	std::ostringstream out_stream;
	out_stream << " outcomes:[";
	for (int i = 0; i < STAT_SIZE; i++)
	{
		out_stream << " (" <<names[i] << ") ";
	}
	out_stream << "]" << std::endl;

	out_stream << " outcomes:[";
	for (int i = 0; i < STAT_SIZE; i++)
	{
		out_stream << stats[i] << " ";
	}
	out_stream << "]" << std::endl;

	out_stream << " outcomes:[" << std::setprecision(3);
	for (int i = 0; i < STAT_SIZE; i++)
	{
		out_stream << 100.0 * stats[i] / normalizer << " ";
	}
	out_stream << "] %" << std::endl;

	return out_stream.str();
}