extern "C"
{
#include "sph/sph_blake.h"
#include "sph/sph_bmw.h"
#include "sph/sph_groestl.h"
#include "sph/sph_skein.h"
#include "sph/sph_jh.h"
#include "sph/sph_keccak.h"

#include "sph/sph_luffa.h"
#include "sph/sph_cubehash.h"
#include "sph/sph_shavite.h"
#include "sph/sph_simd.h"
#include "sph/sph_echo.h"
}

#include "miner.h"
//#include <cuda.h>
//#include <cuda_runtime.h>
#include "cuda_helper.h"

#include <stdio.h>
#include <memory.h>


static uint32_t *d_hash[MAX_GPUS];
static uint32_t foundnonces[MAX_GPUS][2];


extern void quark_blake512_cpu_init(int thr_id);
extern void quark_blake512_cpu_setBlock_80(uint64_t *pdata);
extern void quark_blake512_cpu_setBlock_80_multi(uint32_t thr_id, uint64_t *pdata);
extern void quark_blake512_cpu_hash_80(uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void quark_blake512_cpu_hash_80_multi(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void quark_bmw512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_groestl512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_skein512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_keccak512_cpu_init(int thr_id, uint32_t threads);
extern void quark_keccak512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void cuda_jh512Keccak512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x11_luffaCubehash512_cpu_init(int thr_id, uint32_t threads);
extern void x11_luffaCubehash512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x11_shavite512_cpu_init(int thr_id, uint32_t threads);
extern void x11_shavite512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern int  x11_simd512_cpu_init(int thr_id, uint32_t threads);
extern void x11_simd512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, const uint32_t simdthreads);

extern void x11_echo512_cpu_init(int thr_id, uint32_t threads);
extern void x11_echo512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void x11_echo512_cpu_hash_64_final(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, uint32_t target, uint32_t *h_found);
extern void x11_echo512_cpu_init(int thr_id, uint32_t threads);

extern void quark_compactTest_cpu_init(int thr_id, uint32_t threads);
extern void quark_compactTest_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *inpHashes,
	uint32_t *d_noncesTrue, uint32_t *nrmTrue, uint32_t *d_noncesFalse, uint32_t *nrmFalse);

extern "C" void c11hash(void *output, const void *input)
{
			// blake1-bmw2-grs3-skein4-jh5-keccak6-luffa7-cubehash8-shavite9-simd10-echo11
		sph_blake512_context ctx_blake;
		sph_bmw512_context ctx_bmw;
		sph_groestl512_context ctx_groestl;
		sph_jh512_context ctx_jh;
		sph_keccak512_context ctx_keccak;
		sph_skein512_context ctx_skein;
		sph_luffa512_context ctx_luffa;
		sph_cubehash512_context ctx_cubehash;
		sph_shavite512_context ctx_shavite;
		sph_simd512_context ctx_simd;
		sph_echo512_context ctx_echo;
		
		unsigned char hash[128];
		memset(hash, 0, sizeof hash);
		
		sph_blake512_init(&ctx_blake);
		sph_blake512(&ctx_blake, input, 80);
		sph_blake512_close(&ctx_blake, (void*)hash);
		
		sph_bmw512_init(&ctx_bmw);
		sph_bmw512(&ctx_bmw, (const void*)hash, 64);
		sph_bmw512_close(&ctx_bmw, (void*)hash);
		
		sph_groestl512_init(&ctx_groestl);
		sph_groestl512(&ctx_groestl, (const void*)hash, 64);
		sph_groestl512_close(&ctx_groestl, (void*)hash);
		
		sph_jh512_init(&ctx_jh);
		sph_jh512(&ctx_jh, (const void*)hash, 64);
		sph_jh512_close(&ctx_jh, (void*)hash);
		
		sph_keccak512_init(&ctx_keccak);
		sph_keccak512(&ctx_keccak, (const void*)hash, 64);
		sph_keccak512_close(&ctx_keccak, (void*)hash);
		
		sph_skein512_init(&ctx_skein);
		sph_skein512(&ctx_skein, (const void*)hash, 64);
		sph_skein512_close(&ctx_skein, (void*)hash);
		
		sph_luffa512_init(&ctx_luffa);
		sph_luffa512(&ctx_luffa, (const void*)hash, 64);
		sph_luffa512_close(&ctx_luffa, (void*)hash);
		
		sph_cubehash512_init(&ctx_cubehash);
		sph_cubehash512(&ctx_cubehash, (const void*)hash, 64);
		sph_cubehash512_close(&ctx_cubehash, (void*)hash);
		
		sph_shavite512_init(&ctx_shavite);
		sph_shavite512(&ctx_shavite, (const void*)hash, 64);
		sph_shavite512_close(&ctx_shavite, (void*)hash);
		
		sph_simd512_init(&ctx_simd);
		sph_simd512(&ctx_simd, (const void*)hash, 64);
		sph_simd512_close(&ctx_simd, (void*)hash);
		
		sph_echo512_init(&ctx_echo);
		sph_echo512(&ctx_echo, (const void*)hash, 64);
		sph_echo512_close(&ctx_echo, (void*)hash);
		
		memcpy(output, hash, 32);
}
static bool init[MAX_GPUS] = { 0 };
static uint32_t endiandata[MAX_GPUS][20];

extern "C" int scanhash_c11(int thr_id, uint32_t *pdata,
	const uint32_t *ptarget, uint32_t max_nonce,
	unsigned long *hashes_done)
{
	const uint32_t first_nonce = pdata[19];

	int intensity = (device_sm[device_map[thr_id]] > 500) ? 256 * 256 * 21 : 256 * 256 * 10;
	uint32_t simdthreads = (device_sm[device_map[thr_id]] > 500) ? 256 : 32;

	uint32_t throughput = device_intensity(device_map[thr_id], __func__, intensity);

	if (opt_benchmark)
		((uint32_t*)ptarget)[7] = 0x4f;

	if (!init[thr_id])
	{
		cudaSetDevice(device_map[thr_id]);
		cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
		if (opt_n_gputhreads == 1)
		{
			cudaDeviceSetCacheConfig(cudaFuncCachePreferL1);
		}

		x11_echo512_cpu_init(thr_id, throughput);
		if (x11_simd512_cpu_init(thr_id, throughput) != 0) {
			return 0;
		}
		CUDA_CALL_OR_RET_X(cudaMalloc(&d_hash[thr_id], 64 * throughput), 0); // why 64 ?
		quark_blake512_cpu_init(thr_id);
		init[thr_id] = true;
	}
	for (int k = 0; k < 20; k++)
		be32enc(&endiandata[thr_id][k], ((uint32_t*)pdata)[k]);


	if (opt_n_gputhreads > 1)
	{
		quark_blake512_cpu_setBlock_80_multi(thr_id, (uint64_t *)endiandata[thr_id]);
	}
	else
	{
		quark_blake512_cpu_setBlock_80((uint64_t *)endiandata[thr_id]);
	}

	do {

		if (opt_n_gputhreads > 1)
		{
			quark_blake512_cpu_hash_80_multi(thr_id, throughput, pdata[19], d_hash[thr_id]);
		}
		else
		{
			quark_blake512_cpu_hash_80(throughput, pdata[19], d_hash[thr_id]);
		}
		quark_bmw512_cpu_hash_64(throughput, pdata[19], NULL, d_hash[thr_id]);
		quark_groestl512_cpu_hash_64(throughput, pdata[19], NULL, d_hash[thr_id]);
		cuda_jh512Keccak512_cpu_hash_64(throughput, pdata[19], d_hash[thr_id]);
		quark_skein512_cpu_hash_64(throughput, pdata[19], NULL, d_hash[thr_id]);
		x11_luffaCubehash512_cpu_hash_64(throughput, pdata[19], d_hash[thr_id]);
		x11_shavite512_cpu_hash_64(throughput, pdata[19], d_hash[thr_id]);
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id], simdthreads);
		x11_echo512_cpu_hash_64_final(thr_id, throughput, pdata[19], d_hash[thr_id], ptarget[7], foundnonces[thr_id]);
		if (foundnonces[thr_id][0] != 0xffffffff)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8];
			be32enc(&endiandata[thr_id][19], foundnonces[thr_id][0]);
			c11hash(vhash64, endiandata[thr_id]);

			if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (foundnonces[thr_id][1] != 0xffffffff)
				{
					pdata[21] = foundnonces[thr_id][1];
					res++;
					if (opt_benchmark)
						applog(LOG_INFO, "GPU #%d Found second nounce %08x", thr_id, foundnonces[thr_id][1], vhash64[7], Htarg);
				}
				pdata[19] = foundnonces[thr_id][0];
				if (opt_benchmark)
					applog(LOG_INFO, "GPU #%d Found nounce %08x", thr_id, foundnonces[thr_id][0], vhash64[7], Htarg);
				return res;
			}
			else
			{
				if (vhash64[7] != Htarg)
				{
					applog(LOG_INFO, "GPU #%d: result for %08x does not validate on CPU!", thr_id, foundnonces[thr_id][0]);
				}
			}
		}
		pdata[19] += throughput;
	} while (!scan_abort_flag && !work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));

	*hashes_done = pdata[19] - first_nonce;
	return 0;
}
