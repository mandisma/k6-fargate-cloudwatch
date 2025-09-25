/**
 * Smoke testing is a preliminary type of testing that checks if the basic, critical
 * functionalities of an application are working as expected. It is a simple sanity check
 * to ensure that the application is stable enough for more detailed testing.
 *
 * In this k6 script, we perform a smoke test by:
 * - Running a small number of virtual users (5 VUs)
 * - For a short duration (1 minute)
 * - Making simple HTTP GET requests to verify basic system availability
 * - Without complex test scenarios or heavy load
 */

import http from 'k6/http';
import {sleep} from 'k6';

export const options = {
    duration: '1m',
    vus: 5,
    // thresholds: {
    //   http_req_duration: ['p(95)<500'],
    // },
};

export default function () {
    const res = http.get('https://test.k6.io');
    sleep(1);
}