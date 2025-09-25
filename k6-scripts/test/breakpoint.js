/**
 * Breakpoint Testing with k6
 *
 * Breakpoint testing is a type of performance testing that aims to identify the maximum load
 * a system can handle before it breaks or becomes unresponsive. This test gradually increases
 * the load until the system reaches its breaking point, characterized by:
 * - Increased response times
 * - Higher error rates
 * - Resource exhaustion
 * - System crashes or failures
 */
import http from 'k6/http';
import {sleep} from 'k6';

export const options = {
    executor: 'ramping-arrival-rate',
    stages: [
        {duration: '2h', target: 20000}, // just slowly ramp up to 20k users over 2 hours
    ]
};

export default function () {
    const res = http.get('https://test.k6.io');
    sleep(1);
}
